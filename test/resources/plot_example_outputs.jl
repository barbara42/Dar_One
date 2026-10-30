# Optional plots of synthetic fixture output for local debugging.
# These short-run figures are not reproductions of the manuscript results.
using NCDatasets
using Plots

# The CI plots examine the quantities shown in the scientific documentation
# figures, using the short integration-test simulations and their input fixtures.
const darwin = abspath(get(ENV, "DARONE_MITGCM_PATH", "/dar_one_docker/darwin3"))
const run_root = joinpath(darwin, "verification", "dar_one_config", "run")
const suffix = get(ENV, "DARONE_EXAMPLE_ID_SUFFIX", "")
const plot_dir = joinpath(get(ENV, "DARONE_EXAMPLE_PLOT_DIR", joinpath(tempdir(), "darone-example-plots")), "generated")
mkpath(plot_dir)

gr()

function output_files(name)
    rundir = joinpath(run_root, name * suffix, "run")
    folders = sort(filter(f -> startswith(f, "ecco_gud_") && isdir(joinpath(rundir, f)), readdir(rundir)))
    for folder in reverse(folders)
        dir = joinpath(rundir, folder)
        files = sort(filter(f -> startswith(f, "3d.") && endswith(f, ".nc"), readdir(dir)))
        isempty(files) || return joinpath.(Ref(dir), files)
    end
    error("No 3d NetCDF diagnostics found for $name")
end

function biomass_series(name)
    values = Float64[]
    for file in output_files(name)
        NCDataset(file) do ds
            biomass = zeros(Float64, size(ds["TRAC21"], 4))
            for i in 21:69  # Species included in the documentation's bottle notebook
                biomass .+= Float64.(coalesce.(ds["TRAC$i"][1, 1, 1, :], NaN))
            end
            append!(values, biomass)
        end
    end
    return values
end

function surface(ds, tracer)
    Float64.(coalesce.(ds[tracer][:, :, 1, end], NaN))
end

# Bottle experiment: reproduce the documented *quantity* (total biomass),
# contrasting the control with a tenfold nitrate amendment.
days = 56 / 8  # The bottle case study runs its documented seven-day experiment.
bottle = plot(title="Incubation Timeseries", xlabel="Days", ylabel="total_biomass [mmol C/l]", legend=:topright)
for (treatment, label, color, linestyle) in (("control", "control", :green, :dash),
                                              ("with-no3", "added 10x NO3", :skyblue, :solid))
    biomass = biomass_series("bottle-$treatment-203-109")
    plot!(bottle, range(0, days; length=length(biomass)), biomass;
          label, color, linestyle, linewidth=3)
end
savefig(bottle, joinpath(plot_dir, "bottle_experiment_ci.png"))

# Global steady state: use the documented Bray-Curtis definition, excluding
# diazotrophs, to compare the simulated community with the input reference.
# The full documentation figure also includes explanatory panels A and B.
numerator = zeros(Float64, 360, 160)
denominator = zeros(Float64, 360, 160)
seed_file = joinpath(get(ENV, "DARONE_DATA_DIR", "/dar_one_docker"), "3d.nc")
NCDataset(seed_file) do seed
    for x in ((1, 90), (91, 180), (181, 270), (271, 360))
        for y in ((1, 40), (41, 80), (81, 120), (121, 160))
            name = "globe-ss-$(x[1])-$(x[2])-$(y[1])-$(y[2])"
            xr, yr = x[1]:x[2], y[1]:y[2]
            NCDataset(last(output_files(name))) do ds
                for i in Iterators.flatten((21:29, 35:70))
                    tracer = "TRAC$i"
                    initial = Float64.(coalesce.(seed[tracer][xr, yr, 1, 1], NaN))
                    final = surface(ds, tracer)
                    @assert size(final) == (90, 40) "Unexpected tile dimensions for $name"
                    numerator[xr, yr] .+= 2 .* min.(initial, final)
                    denominator[xr, yr] .+= initial .+ final
                end
            end
        end
    end
end
bray_curtis = 1 .- numerator ./ denominator
bray_curtis[denominator .<= 0] .= NaN
any(isfinite, bray_curtis) || error("Global Bray-Curtis map contains no finite values")
figure = heatmap(0:359, -80:79, permutedims(bray_curtis);
                 title="Bray-Curtis Dissimilarity between Steady-State and Global",
                 xlabel="longitude", ylabel="latitude", color=:viridis,
                 clims=(0, 1), size=(1200, 650))
savefig(figure, joinpath(plot_dir, "Fig_Bray_Curtis_ci.png"))

# Nitrogen-fixer niche: plot the total diazotroph biomass against the nitrate
# and phosphate axes used to initialise the 30x30 grid.
NCDataset(last(output_files("n_30x30"))) do ds
    diazotrophs = sum(surface(ds, "TRAC$i") for i in 30:34)
    any(isfinite, diazotrophs) || error("Diazotroph map contains no finite values")
    figure = heatmap(range(0, 0.1; length=30), range(0, 0.05; length=30),
                     permutedims(diazotrophs); title="Total Diazotroph Biomass",
                     xlabel="NO3 (mmol N)", ylabel="PO4 (mmol P)",
                     color=:viridis, colorbar_title="mmol C", size=(800, 580))
    savefig(figure, joinpath(plot_dir, "NfixerPhase_ci.png"))
end

println("Saved documentation-aligned CI plots to ", abspath(plot_dir))
