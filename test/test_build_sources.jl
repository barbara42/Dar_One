using Test, DarOne, Scratch

const LEGACY_COG = """
import copy, getopt, hashlib, imp, os, re, shlex, sys, traceback
class Cog:
    def installCogModule(self):
        self.cogmodule = imp.new_module('cog')
"""

@testset "Writable Darwin3 build sources and legacy Cog" begin
    mktempdir() do root
        source = joinpath(root, "darwin source")
        file = joinpath(source, "tools", "darwin", "cogapp", "cogapp.py")
        mkpath(dirname(file))
        write(file, LEGACY_COG)
        config = joinpath(root, "separate configuration")
        mkpath(config)

        withenv("DARONE_MITGCM_PATH" => source, "DARONE_CONFIG_PATH" => config) do
            DarOne._with_build_source(base_configuration) do built
                generated = joinpath(built, "tools", "darwin", "cogapp", "cogapp.py")
                text = read(generated, String)
                @test occursin("from types import ModuleType", text)
                @test occursin("ModuleType('cog')", text)
                @test !occursin("imp.new_module", text)
                @test DarOne._patch_legacy_cog!(built) == false
                write(joinpath(built, "generated.F"), "generated Fortran\n")
            end
            @test read(file, String) == LEGACY_COG
            @test !isfile(joinpath(source, "generated.F"))
            @test occursin("legacy_cog_compatibility=true",
                read(joinpath(DarOne._build_workspace(base_configuration), "source-provenance.txt"), String))
            # Rebuilding starts from the original source, not previous output.
            DarOne._with_build_source(base_configuration) do built
                @test !isfile(joinpath(built, "generated.F"))
            end
        end

        write(file, "from types import ModuleType\n")
        @test !DarOne._patch_legacy_cog!(source)
        @test read(file, String) == "from types import ModuleType\n"
        write(file, "import imp\nself.cogmodule = imp.new_module('cog')\n")
        @test_throws ErrorException DarOne._patch_legacy_cog!(source)
    end

    # A pinned Git cache is exported from HEAD, even if an earlier build
    # accidentally left its working tree dirty.
    mktempdir() do root
        Scratch.with_scratch_directory(joinpath(root, "scratch")) do
            source = joinpath(Scratch.get_scratch!(DarOne, "darwin-sources"),
                              "darwin", "test", "revision")
            mkpath(source)
            run(`git init -q $source`)
            run(`git -C $source config user.name DarOne-Tests`)
            run(`git -C $source config user.email darone-tests@localhost`)
            file = joinpath(source, "tracked.txt")
            write(file, "committed\n")
            run(`git -C $source add tracked.txt`)
            run(`git -C $source -c commit.gpgsign=false commit -qm initial`)
            write(file, "modified\n")
            write(joinpath(source, "untracked.txt"), "generated\n")
            copied = DarOne._copy_build_source!(source, joinpath(root, "export with spaces"))
            @test read(joinpath(copied, "tracked.txt"), String) == "committed\n"
            @test !isfile(joinpath(copied, "untracked.txt"))
            @test read(file, String) == "modified\n"
        end
    end
end
