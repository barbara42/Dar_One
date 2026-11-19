using Test
using DarOne
using NCDatasets

@testset "MNC NetCDF tile reading" begin
    mktempdir() do directory
        for (prefix, dimensions, trailing) in (
            ("grid2d", ("X", "Y"), ()),
            ("grid3d_depth", ("X", "Y", "RC"), (2,)),
            ("grid3d_time", ("X", "Y", "iter"), (2,)),
            ("grid4d", ("X", "Y", "RC", "iter"), (2, 3)),
        )
            tiles = []
            for bi in 1:2
                shape = (2, 3, trailing...)
                values = reshape(Float32.(1:prod(shape)), shape) .+ 100f0 * bi
                push!(tiles, values)
                NCDataset(joinpath(directory, "$prefix.$bi.nc"), "c") do ds
                    for (name, n) in zip(dimensions, shape)
                        defDim(ds, name, n)
                    end
                    for (key, value) in ("Nx" => 4, "Ny" => 3, "sNx" => 2,
                                         "sNy" => 3, "bi" => bi, "bj" => 1)
                        ds.attrib[key] = value
                    end
                    defVar(ds, "XC", values, dimensions)
                end
            end
            result = DarOne.read_mnc(directory, prefix, "XC")
            @test size(result) == (4, 3, trailing...)
            @test eltype(result) == Float64
            @test result == Float64.(cat(tiles...; dims=1))
        end
        @test_throws ArgumentError DarOne.read_mnc(directory, "missing", "XC")
    end
end
