using NCDatasets

# Export one tile (x, y), or all four y tiles for a given x.
const x_bounds = ((1, 90), (91, 180), (181, 270), (271, 360))
const y_bounds = ((1, 40), (41, 80), (81, 120), (121, 160))
const species = (21:29, 35:70)  # The published comparison excludes diazotrophs.

length(ARGS) in (1, 2) || error("Expected x-tile index and optional y-tile index")
x_tile = parse(Int, ARGS[1])
1 <= x_tile <= 4 || error("Expected x-tile index between 1 and 4")
y_tiles = length(ARGS) == 2 ? (parse(Int, ARGS[2]),) : 1:4
all(1 <= y <= 4 for y in y_tiles) || error("Expected y-tile index between 1 and 4")
x1, x2 = x_bounds[x_tile]

darwin = abspath(get(ENV, "DARONE_MITGCM_PATH", "/dar_one_docker/darwin3"))
run_root = joinpath(darwin, "verification", "dar_one_config", "run")
seed_file = joinpath(get(ENV, "DARONE_DATA_DIR", "/dar_one_docker"), "3d.nc")
output_dir = get(ENV, "DARONE_BRAY_TILE_DIR", joinpath(pwd(), "bray-curtis-tiles"))
mkpath(output_dir)

function annual_outputs(run_name)
    rundir = joinpath(run_root, run_name, "run")
    isdir(rundir) || error("Missing experiment directory: $rundir")

    # MNC typically writes 3d.*.nc under ecco_gud_*, but the output
    # directory can vary between MITgcm configurations.
    files = sort([joinpath(dir, file) for (dir, _, names) in walkdir(rundir)
                  for file in names if startswith(file, "3d.") && endswith(file, ".nc")])
    records = Tuple{String, Int}[]
    counts = Pair{String, Int}[]
    for file in files
        n = NCDataset(file) do ds
            size(ds["TRAC21"], 4)
        end
        push!(counts, relpath(file, rundir) => n)
        append!(records, ((file, i) for i in 1:n))
    end

    if length(records) < 2
        candidates = sort([relpath(joinpath(dir, file), rundir)
                           for (dir, _, names) in walkdir(rundir)
                           for file in names if startswith(file, "3d")])
        error("Expected two annual diagnostic records for $run_name, found $(length(records)) " *
              "across $(length(files)) NetCDF files. Records: $counts. " *
              "Other 3d outputs: $(first(candidates, min(length(candidates), 20))). " *
              "Inspect the Fortran log and data.diagnostics in $rundir.")
    end
    return last(records, 2)
end

function surface(ds, variable, x, y, t)
    a = Float64.(coalesce.(ds[variable][x, y, 1, t], 0.0))
    a[.!isfinite.(a)] .= 0.0
    return a
end

NCDataset(seed_file) do reference
    for y_tile in y_tiles
        y1, y2 = y_bounds[y_tile]
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
