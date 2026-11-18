using Test
using DarOne

@testset "Darwin3 and configuration paths" begin
    mktempdir() do root
        darwin = joinpath(root, "darwin source")
        separate = joinpath(root, "independent dar_one_config")
        mkpath(darwin)
        mkpath(separate)
        mkpath(joinpath(darwin, "verification", "dar_one_config"))

        # An externally checked-out configuration needs no link under verification/.
        withenv("DARONE_MITGCM_PATH" => darwin,
                "DARONE_CONFIG_PATH" => separate) do
            @test DarOne.darwin_root() == darwin
            @test DarOne.configuration_root() == separate
            @test DarOne.build_directory() == joinpath(separate, "build")
            @test DarOne.input_directory() == joinpath(separate, "input")
            @test DarOne.run_directory() == joinpath(separate, "run")
            @test DarOne.executable_path() == joinpath(separate, "build", "mitgcmuv")
            @test DarOne.configuration_root("other_config") == joinpath(darwin, "verification", "other_config")

            config, rundir = create_MITgcm_config("trial")
            @test config.folder == joinpath(separate, "run")
            @test rundir == joinpath(separate, "run", "trial", "run")

            original = "../../shared/input.nc\n../input/data\n"
            expanded = DarOne._expand_input_paths(original, base_configuration)
            @test expanded == joinpath(darwin, "verification", "shared", "input.nc") * "\n" *
                              joinpath(separate, "input", "data") * "\n"
            @test endswith(expanded, "\n")
        end

        # Existing verification tree is still the default if no override is set.
        withenv("DARONE_MITGCM_PATH" => darwin,
                "DARONE_CONFIG_PATH" => nothing) do
            @test DarOne.configuration_root() == joinpath(darwin, "verification", "dar_one_config")
            @test DarOne.executable_path() == joinpath(darwin, "verification", "dar_one_config", "build", "mitgcmuv")
        end

        # Legacy scripts that assign to MITgcm_path[1] remain supported.
        original_path = MITgcm_path[1]
        try
            withenv("DARONE_MITGCM_PATH" => nothing,
                    "DARONE_CONFIG_PATH" => nothing) do
                MITgcm_path[1] = darwin
                @test DarOne.darwin_root() == darwin
                @test DarOne.configuration_root() == joinpath(darwin, "verification", "dar_one_config")
            end
        finally
            MITgcm_path[1] = original_path
        end

        withenv("DARONE_MITGCM_PATH" => "",
                "DARONE_CONFIG_PATH" => nothing) do
            @test_throws ArgumentError DarOne.darwin_root()
        end
        withenv("DARONE_MITGCM_PATH" => darwin,
                "DARONE_CONFIG_PATH" => "") do
            @test_throws ArgumentError DarOne.configuration_root()
        end
    end
end
