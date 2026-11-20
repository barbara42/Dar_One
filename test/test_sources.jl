using Test, DarOne, Scratch

# Exercise real Git fetches without relying on GitHub or a Fortran compiler.
# The tiny local repositories contain only the paths required by the resolver.
function _fixture_repo(folder, kind)
    mkpath(folder)
    run(`git init -q $folder`)
    run(`git -C $folder config user.name DarOne-Tests`)
    run(`git -C $folder config user.email darone-tests@localhost`)
    run(`git -C $folder config commit.gpgsign false`)
    if kind === :darwin
        mkpath(joinpath(folder, "tools"))
        write(joinpath(folder, "tools", "genmake2"), "#!/bin/sh\n")
    else
        mkpath(joinpath(folder, "code"))
        mkpath(joinpath(folder, "input"))
        write(joinpath(folder, "code", "SIZE.h"), "original grid\n")
        write(joinpath(folder, "code", "darwin_plankton.F"), "original plankton\n")
        write(joinpath(folder, "input", "data"), "&PARM01\n/\n")
    end
    run(`git -C $folder add .`)
    run(`git -C $folder commit -qm initial`)
    return strip(read(`git -C $folder rev-parse HEAD`, String))
end

@testset "Managed Darwin3 sources" begin
    mktempdir() do root
        scratch = joinpath(root, "scratch directory")
        mkpath(scratch)
        Scratch.with_scratch_directory(scratch) do
            source = joinpath(root, "darwin remote")
            config = joinpath(root, "configuration remote")
            darwin_rev = _fixture_repo(source, :darwin)
            config_rev = _fixture_repo(config, :config)
            legacy_root = MITgcm_path[1]
            try
                MITgcm_path[1] = "/dar_one_docker/darwin3"
                withenv("DARONE_MITGCM_PATH" => nothing,
                        "DARONE_CONFIG_PATH" => nothing,
                        "DARONE_DARWIN_URL" => source,
                        "DARONE_CONFIG_URL" => config,
                        "DARONE_DARWIN_REV" => darwin_rev,
                        "DARONE_CONFIG_REV" => config_rev) do
                    @test source_revisions() == (darwin=darwin_rev, config=config_rev)
                    downloaded = darwin_root()
                    staged = configuration_root()
                    @test isfile(joinpath(downloaded, "tools", "genmake2"))
                    @test isfile(joinpath(staged, "code", "SIZE.h"))
                    @test isdir(joinpath(staged, "build"))
                    @test isdir(joinpath(staged, "run"))
                    @test downloaded == darwin_root()
                    @test staged == configuration_root()
                    @test strip(read(`git -C $downloaded rev-parse HEAD`, String)) == darwin_rev
                    @test strip(read(`git -C $config rev-parse HEAD`, String)) == config_rev

                    # Modifying build-time code never alters the cached source revision.
                    write(joinpath(staged, "code", "SIZE.h"), "modified grid\n")
                    @test read(joinpath(configuration_root(), "code", "SIZE.h"), String) == "modified grid\n"
                    @test read(joinpath(DarOne._source_checkout(:config, config_rev), "code", "SIZE.h"), String) == "original grid\n"

                    # Select another Darwin3 commit without invalidating old workspaces.
                    write(joinpath(source, "new-feature.txt"), "new Darwin source\n")
                    run(`git -C $source add new-feature.txt`)
                    run(`git -C $source commit -qm newer`)
                    newer = strip(read(`git -C $source rev-parse HEAD`, String))
                    withenv("DARONE_DARWIN_REV" => newer) do
                        @test darwin_root() != downloaded
                        @test isfile(joinpath(darwin_root(), "new-feature.txt"))
                        @test configuration_root() != staged
                        @test read(joinpath(configuration_root(), "code", "SIZE.h"), String) == "original grid\n"
                    end
                    @test darwin_root() == downloaded
                    @test configuration_root() == staged

                    # A newer configuration commit receives its own writable copy.
                    write(joinpath(config, "code", "SIZE.h"), "new configuration grid\n")
                    run(`git -C $config add code/SIZE.h`)
                    run(`git -C $config commit -qm new-configuration`)
                    next_config = strip(read(`git -C $config rev-parse HEAD`, String))
                    withenv("DARONE_CONFIG_REV" => next_config) do
                        @test configuration_root() != staged
                        @test read(joinpath(configuration_root(), "code", "SIZE.h"), String) == "new configuration grid\n"
                    end
                    @test configuration_root() == staged
                end
                withenv("DARONE_DARWIN_REV" => "not-a-commit") do
                    @test_throws ArgumentError source_revisions()
                end
                # A user checkout always takes precedence over the managed cache.
                withenv("DARONE_MITGCM_PATH" => source,
                        "DARONE_CONFIG_PATH" => config) do
                    @test darwin_root() == source
                    @test configuration_root() == config
                end
            finally
                MITgcm_path[1] = legacy_root
            end
        end
    end
end
