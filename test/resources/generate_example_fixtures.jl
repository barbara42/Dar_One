using NCDatasets

# The case studies index longitude 1:360, latitude 1:160, depth 1:4, and time 1.
output_dir = isempty(ARGS) ? get(ENV, "DARONE_DATA_DIR", joinpath(@__DIR__, "example_data")) : ARGS[1]
mkpath(output_dir)

function create_dataset(filename, values)
    NCDataset(joinpath(output_dir, filename), "c") do ds
        for (name, size) in (("lon", 360), ("lat", 160), ("depth", 4), ("time", 1))
            defDim(ds, name, size)
        end
        for (name, value) in values
            var = defVar(ds, name, Float32, ("lon", "lat", "depth", "time"); deflatelevel=1)
            var[:, :, :, :] = fill(Float32(value), 360, 160, 4, 1)
        end
    end
end

tracers = fill(0.01f0, 70)
tracers[1] = 2000f0   # DIC
tracers[2] = 5f0      # NO3
tracers[5] = 0.3f0    # PO4
tracers[6] = 0.001f0  # FeT
tracers[7] = 3f0      # SiO2
tracers[18] = 2300f0 # ALK
tracers[19] = 200f0  # O2
tracers[21:70] .= 0.001f0
create_dataset("3d.nc", ["TRAC$(lpad(i, 2, '0'))" => tracers[i] for i in 1:70])
create_dataset("tave.nc", ["Ttave" => 20f0])
create_dataset("par.nc", vcat(
    ["Ed$(lpad(i, 3, '0'))" => 1f0 / i for i in 1:13],
    ["Es$(lpad(i, 3, '0'))" => 0.25f0 / i for i in 1:13],
))

println("Created example inputs in ", abspath(output_dir))
