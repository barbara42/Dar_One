using DarOneTools
using Test

@testset "DarOneTools" begin
    @testset "Namelist round trip" begin
        mktempdir() do dir
            input = joinpath(dir, "data")
            write(input, """
                &PARM01
                 nIter0 = 100,
                 useSingleCpuIO = .TRUE.,
                 tRef = 18.5,
                &
                &PARM02
                 runName = 'test',
                /
                """)

            nml = read_namelist(input)
            @test nml.groups == [:PARM01, :PARM02]
            @test nml.params[1][:nIter0] == 100
            @test nml.params[1][:useSingleCpuIO] === true
            @test nml.params[1][:tRef] == 18.5
            @test nml.params[2][:runName] == "test"

            output = joinpath(dir, "data.out")
            write(output, nml)
            reread = read(output, MITgcm_namelist())
            @test reread.groups == nml.groups
            @test reread.params == nml.params
        end
    end

    @testset "Grid size" begin
        mktempdir() do dir
            fixture = joinpath(@__DIR__, "resources", "test_SIZE.h")
            output = joinpath(dir, "SIZE.h")
            cp(fixture, output)
            update_grid_size(4, 3, output)
            expected = replace(read(fixture, String),
                               "sNx =   1," => "sNx =   4,",
                               "sNy =   1," => "sNy =   3,")
            @test strip(read(output, String)) == strip(expected)
        end
    end

    @testset "Nutrient tendency switches" begin
        mktempdir() do dir
            fixture = joinpath(@__DIR__, "resources", "test_darwin_plankton.F")
            output = joinpath(dir, "darwin_plankton.F")
            cp(fixture, output)
            factors = Float64.(mod.(1:19, 2))
            hold_nutrients_constant(factors, output)

            expected = split(strip(read(fixture, String)), '\n')
            marker = findfirst(==("C DAR1 Nutrients"), expected)
            for (i, factor) in enumerate(factors)
                expected[marker + i] = replace(expected[marker + i], r"\*[01]\.0$" => "*$factor")
            end
            @test split(strip(read(output, String)), '\n') == expected
        end
    end
end
