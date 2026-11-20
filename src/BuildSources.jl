# Generate Fortran source in an isolated, writable tree. MITgcm's genmake2
# runs Cog in pkg/darwin and modifies files beneath -rootdir; it must not
# generate into the immutable, revision-pinned source cache.

const _LEGACY_COG_IMPORT = "import copy, getopt, hashlib, imp, os, re, shlex, sys, traceback"
const _LEGACY_COG_MODULE = "self.cogmodule = imp.new_module('cog')"

function _patch_legacy_cog!(source_root::AbstractString)
    file = joinpath(source_root, "tools", "darwin", "cogapp", "cogapp.py")
    isfile(file) || return false
    original = read(file, String)

    if occursin(_LEGACY_COG_IMPORT, original) && occursin(_LEGACY_COG_MODULE, original)
        patched = replace(original,
            _LEGACY_COG_IMPORT =>
                "import copy, getopt, hashlib, os, re, shlex, sys, traceback\nfrom types import ModuleType",
            _LEGACY_COG_MODULE => "self.cogmodule = ModuleType('cog')")
        write(file, patched)
        return true
    end

    # If a future upstream revision changes the layout of legacy Cog, surface
    # that clearly instead of applying a speculative source-code rewrite.
    if occursin("imp.new_module", original) ||
       occursin(r"(?m)^\s*(?:import\s+[^\n]*\bimp\b|from\s+imp\s+import)", original)
        error("Unsupported legacy Cog implementation at $file; update the compatibility adapter for this Darwin3 revision.")
    end
    return false
end

function _managed_source_path(path::AbstractString)
    cache = joinpath(Scratch.get_scratch!(@__MODULE__, "darwin-sources"), "darwin")
    relative = relpath(abspath(path), abspath(cache))
    return relative != ".." && !startswith(relative, "../") && !startswith(relative, "..\\")
end

function _copy_build_source!(source::AbstractString, destination::AbstractString)
    if _managed_source_path(source)
        # Export HEAD rather than copying a potentially dirtied cache from a
        # previous genmake2 invocation. This keeps the pinned tree reproducible.
        mkpath(destination)
        run(pipeline(_git("-C", source, "archive", "--format=tar", "HEAD"),
                     `tar -xf - -C $destination`))
    else
        # Developer checkouts may have uncommitted source modifications.
        cp(source, destination)
    end
    return destination
end

function _build_workspace(name::AbstractString)
    identity = string(darwin_root(), '\n', configuration_root(name))
    key = bytes2hex(sha256(identity))[1:24]
    folder = joinpath(Scratch.get_scratch!(@__MODULE__, "darwin-build-sources"), key)
    mkpath(folder)
    return folder
end

function _with_build_lock(f::Function, name::AbstractString)
    workspace = _build_workspace(name)
    return FileWatching.Pidfile.mkpidlock(joinpath(workspace, "build.lock"); stale_age=3600) do
        f(workspace)
    end
end

function _source_commit(root::AbstractString)
    ispath(joinpath(root, ".git")) || return "unversioned"
    try
        return strip(read(_git("-C", root, "rev-parse", "HEAD"), String))
    catch
        return "unversioned"
    end
end

function _with_build_source(f::Function, name::AbstractString)
    return _with_build_lock(name) do workspace
        source = darwin_root()
        staging = mktempdir(workspace; prefix=".source-")
        try
            prepared = _copy_build_source!(source, joinpath(staging, "darwin3"))
            patched = _patch_legacy_cog!(prepared)
            destination = joinpath(workspace, "darwin3")
            rm(destination; recursive=true, force=true)
            mv(prepared, destination)
            open(joinpath(workspace, "source-provenance.txt"), "w") do io
                println(io, "darwin_source=", source)
                println(io, "darwin_revision=", _source_commit(source))
                println(io, "configuration=", configuration_root(name))
                python = Sys.which("python")
                println(io, "python_executable=", something(python, "unavailable"))
                version = python === nothing ? "unavailable" : strip(read(`$python --version`, String))
                println(io, "python_version=", version)
                println(io, "legacy_cog_compatibility=", patched)
            end
            patched && @info "Applied legacy Cog Python compatibility in the writable Darwin3 build source" destination
            return f(destination)
        finally
            isdir(staging) && rm(staging; recursive=true, force=true)
        end
    end
end
