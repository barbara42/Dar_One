using NCDatasets
using Plots

# Stitch the 16 independently computed tiles into the manuscript's 360x160 map.
source_dir = abspath(ARGS[1])
output_dir = abspath(ARGS[2])
mkpath(output_dir)

field = fill(NaN32, 360, 160)
for x in 1:4, y in 1:4
    file = joinpath(source_dir, "bray-x$x-y$y.nc")
    isfile(file) || error("Missing Bray-Curtis tile $file")
    NCDataset(file) do ds
        data = ds["bray_curtis"][:, :]
        size(data) == (90, 40) || error("Unexpected dimensions in $file")
        field[(90*x - 89):(90*x), (40*y - 39):(40*y)] .= data
    end
end
any(isfinite, field) || error("Assembled Bray-Curtis map has no finite values")

NCDataset(joinpath(output_dir, "Fig_Bray_Curtis.nc"), "c") do output
    defDim(output, "longitude", 360)
    defDim(output, "latitude", 160)
    defVar(output, "longitude", Float32, ("longitude",))[:] = Float32.(0:359)
    defVar(output, "latitude", Float32, ("latitude",))[:] = Float32.(-80:79)
    defVar(output, "bray_curtis", Float32, ("longitude", "latitude"))[:, :] = field
end

gr()
figure = heatmap(0:359, -80:79, permutedims(field);
                 title="Bray-Curtis Dissimilarity between Steady-State and Global",
                 xlabel="longitude", ylabel="latitude", color=:viridis,
                 clims=(0, 1), size=(1200, 650))
savefig(figure, joinpath(output_dir, "Fig_Bray_Curtis.png"))
println("Saved full Bray-Curtis map and NetCDF to ", output_dir)
