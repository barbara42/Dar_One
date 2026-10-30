using NCDatasets

# Export four sections of the full-resolution Bray-Curtis map after a long DAR1 run.
# Each x tile is simulated by a separate process on the same CI runner.
const x_bounds = ((1, 90), (91, 180), (181, 270), (271, 360))
const y_bounds = ((1, 40), (41, 80), (81, 120), (121, 160))
const species = (21:29, 35:70)  # The published comparison excludes diazotrophs.

x_tile = parse(Int, only(ARGS))
1 <= x_tile <= 4 || error("Expected x-tile index between 1 and 4")
x1, x2 = x_bounds[x_tile]

darwin = abspath(get(ENV, "DARONE_MITGCM_PATH", "/dar_one_docker/darwin3"))
run_root = joinpath(darwin, "verification", "dar_one_config", "run")
seed_file = joinpath(get(ENV, "DARONE_DATA_DIR", "/dar_one_docker"), "3d.nc")
output_dir = get(ENV, "DARONE_BRAY_TILE_DIR", joinpath(pwd(), "bray-curtis-tiles"))
mkpath(output_dir)

function annual_outputs(run_name)
    rundir = joinpath(run_root, run_name, "run")
    folders = sort(filter(d -> startswith(d, "ecco_gud_") && isdir(joinpath(rundir, d)), readdir(rundir)))
    records = Tuple{String, Int}[]
    for folder in folders
        dir = joinpath(rundir, folder)
        files = sort(filter(f -> startswith(f, "3d.") && endswith(f, ".nc"), readdir(dir)))
        for file in files
            path = joinpath(dir, file)
            NCDataset(path) do ds
                append!(records, ((path, i) for i in 1:size(ds["TRAC21"], 4)))
            end
        end
    end
    length(records) >= 2 || error("Expected two annual diagnostics for $run_name, found $(length(records))")
    return last(records, 2)
end

function surface(ds, variable, x, y, t)
    a = Float64.(coalesce.(ds[variable][x, y, 1, t], 0.0))
    a[.!isfinite.(a)] .= 0.0
    return a
end

NCDataset(seed_file) do reference
    for (y_tile, (y1, y2)) in enumerate(y_bounds)
        run_name = "globe-ss-$x1-$x2-$y1-$y2"
        records = annual_outputs(run_name)
        numerator = zeros(Float64, 90, 40)
        denominator = zeros(Float64, 90, 40)
        NCDataset(records[1][1]) do previous
            NCDataset(records[2][1]) do current
                for ids in species, i in ids
                    var = "TRAC$i"
                    original = surface(reference, var, x1:x2, y1:y2, 1)
                    final_mean = (surface(previous, var, :, :, records[1][2]) .+
                                  surface(current, var, :, :, records[2][2])) ./ 2
                    size(final_mean) == size(original) || error("Unexpected dimensions for $var in $run_name")
                    numerator .+= 2 .* min.(original, final_mean)
                    denominator .+= original .+ final_mean
                end
            end
        end
        dissimilarity = fill(NaN, size(numerator))
        valid = denominator .> 0
        dissimilarity[valid] .= 1 .- numerator[valid] ./ denominator[valid]
        any(isfinite, dissimilarity) || error("No finite Bray-Curtis values in $run_name")
        all(v -> 0 <= v <= 1, dissimilarity[valid]) || error("Bray-Curtis values outside [0, 1] in $run_name")

        destination = joinpath(output_dir, "bray-x$(x_tile)-y$(y_tile).nc")
        NCDataset(destination, "c") do output
            defDim(output, "longitude", 90)
            defDim(output, "latitude", 40)
            defVar(output, "bray_curtis", Float32, ("longitude", "latitude"))[:, :] = Float32.(dissimilarity)
            output.attrib["experiment"] = run_name
            output.attrib["averaging"] = "last two annual diagnostic records"
        end
        println("Wrote ", destination)
    end
end
