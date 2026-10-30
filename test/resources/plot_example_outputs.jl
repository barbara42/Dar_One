using NCDatasets
using Plots

# Plot the NetCDF diagnostics produced by the short integration-test runs.
const darwin = abspath(get(ENV, "DARONE_MITGCM_PATH", "/dar_one_docker/darwin3"))
const run_root = joinpath(darwin, "verification", "dar_one_config", "run")
const suffix = get(ENV, "DARONE_EXAMPLE_ID_SUFFIX", "")
const plot_dir = get(ENV, "DARONE_EXAMPLE_PLOT_DIR", joinpath(tempdir(), "darone-example-plots"))
mkpath(plot_dir)

gr()

function output_file(name)
    rundir = joinpath(run_root, name * suffix, "run")
    folders = sort(filter(f -> startswith(f, "ecco_gud_") && isdir(joinpath(rundir, f)), readdir(rundir)))
    for folder in reverse(folders)
        dir = joinpath(rundir, folder)
        files = sort(filter(f -> startswith(f, "3d.") && endswith(f, ".nc"), readdir(dir)))
        isempty(files) || return joinpath(dir, last(files))
    end
    error("No 3d NetCDF diagnostics found for $name")
end

function series(name, tracer)
    NCDataset(output_file(name)) do ds
        Float64.(coalesce.(ds[tracer][1, 1, 1, :], NaN))
    end
end

function surface(ds, tracer)
    Float64.(coalesce.(ds[tracer][:, :, 1, end], NaN))
end

function field_plot(data, title; xlabel="X grid index", ylabel="Y grid index")
    heatmap(1:size(data, 1), 1:size(data, 2), permutedims(data);
            title, xlabel, ylabel, aspect_ratio=:equal, colorbar=true)
end

# Beginner tutorial: compare both picophytoplankton groups.
beginner = "beginner_tutorial-pro-syn-2"
p = plot(title="Beginner tutorial: picophytoplankton", xlabel="Output record",
         ylabel="Biomass (model tracer units)", legend=:best)
for (tracer, label) in (("TRAC21", "Prochlorococcus"), ("TRAC22", "Synechococcus"))
    values = series(beginner, tracer)
    plot!(p, 1:length(values), values; label, marker=:circle)
end
savefig(p, joinpath(plot_dir, "beginner_plankton.png"))

# Bottle experiment: three treatments, with nutrient and biomass responses.
treatments = (("control", "Control"), ("with-no3", "Added nitrate"), ("with-nh4", "Added ammonium"))
plots = [plot(title=title, xlabel="Output record", ylabel="Model tracer units", legend=:best)
         for title in ("Nitrate (TRAC02)", "Ammonium (TRAC04)", "Prochlorococcus (TRAC21)")]
for (treatment, label) in treatments
    name = "bottle-$treatment-203-109"
    for (p, tracer) in zip(plots, ("TRAC02", "TRAC04", "TRAC21"))
        values = series(name, tracer)
        plot!(p, 1:length(values), values; label, marker=:circle)
    end
end
savefig(plot(plots...; layout=(3, 1), size=(950, 900)), joinpath(plot_dir, "bottle_experiment.png"))

# Global steady state: assemble all 16 spatial tiles in their original positions.
pro = fill(NaN, 360, 160)
no3 = fill(NaN, 360, 160)
for x in ((1, 90), (91, 180), (181, 270), (271, 360))
    for y in ((1, 40), (41, 80), (81, 120), (121, 160))
        name = "globe-ss-$(x[1])-$(x[2])-$(y[1])-$(y[2])"
        NCDataset(output_file(name)) do ds
            for (array, tracer) in ((pro, "TRAC21"), (no3, "TRAC02"))
                tile = surface(ds, tracer)
                @assert size(tile) == (90, 40) "Unexpected tile size for $name: $(size(tile))"
                array[x[1]:x[2], y[1]:y[2]] .= tile
            end
        end
    end
end
any(isfinite, pro) && any(isfinite, no3) || error("Global tracer maps contain no finite values")
global_plots = [field_plot(pro, "Prochlorococcus (TRAC21)"),
                field_plot(no3, "Nitrate (TRAC02)")]
for p in global_plots
    vline!(p, [90.5, 180.5, 270.5]; color=:white, alpha=0.5, label="")
    hline!(p, [40.5, 80.5, 120.5]; color=:white, alpha=0.5, label="")
end
savefig(plot(global_plots...; layout=(2, 1), size=(1050, 760)),
        joinpath(plot_dir, "global_steady_state.png"))

# Nitrogen fixers: inspect the diazotroph community across NO3 and PO4 gradients.
NCDataset(output_file("n_30x30")) do ds
    diazotrophs = sum(surface(ds, "TRAC$(lpad(i, 2, '0'))") for i in 30:34)
    nfix_plots = [field_plot(diazotrophs, "Diazotrophs (TRAC30-34)"),
                  field_plot(surface(ds, "TRAC02"), "Nitrate (TRAC02)"),
                  field_plot(surface(ds, "TRAC05"), "Phosphate (TRAC05)")]
    savefig(plot(nfix_plots...; layout=(1, 3), size=(1500, 470)),
            joinpath(plot_dir, "nitrogen_fixers.png"))
end

println("Saved example plots to ", abspath(plot_dir))
