using FileWatching, SHA, Scratch

const _DARWIN_REMOTE = "https://github.com/darwinproject/darwin3.git"
const _CONFIG_REMOTE = "https://github.com/barbara42/dar_one_config.git"
const _LEGACY_DOCKER_ROOT = "/dar_one_docker/darwin3"

# Keep the scientific defaults in one file, shared with the release/CI tooling.
function _pinned_revision(name::String)
    for line in eachline(joinpath(@__DIR__, "..", "darwin-sources.env"))
        startswith(line, name * "=") || continue
        return strip(split(line, '='; limit=2)[2])
    end
    error("Missing $name in darwin-sources.env")
end

function _full_revision(revision::AbstractString, name::AbstractString)
    occursin(r"^[0-9a-fA-F]{40}$", revision) ||
        throw(ArgumentError("$name must be a complete 40-character Git commit SHA, got: $revision"))
    return lowercase(String(revision))
end

"""
    source_revisions()

Return the Darwin3 and `dar_one_config` commits requested for managed sources.
An explicitly supplied local checkout can be at a different revision.
The default commits are recorded in `darwin-sources.env`. Override them with
`DARONE_DARWIN_REV` and `DARONE_CONFIG_REV`, respectively (or legacy `DARWIN_REV`).
"""
function source_revisions()
    darwin = get(ENV, "DARONE_DARWIN_REV", get(ENV, "DARWIN_REV", _pinned_revision("DARWIN_REV")))
    config = get(ENV, "DARONE_CONFIG_REV", _pinned_revision("DARONE_CONFIG_REV"))
    return (darwin=_full_revision(darwin, "DARONE_DARWIN_REV"),
            config=_full_revision(config, "DARONE_CONFIG_REV"))
end

_source_url(kind::Symbol) = get(ENV, kind === :darwin ? "DARONE_DARWIN_URL" : "DARONE_CONFIG_URL",
                                kind === :darwin ? _DARWIN_REMOTE : _CONFIG_REMOTE)

function _git(args...)
    git = Sys.which("git")
    git === nothing && error("Git is required to obtain Darwin3 sources. Install git or set DARONE_MITGCM_PATH and DARONE_CONFIG_PATH.")
    return Cmd(vcat(String[git], String[args...]))
end

function _check_source(root::AbstractString, kind::Symbol)
    required = kind === :darwin ? ("tools/genmake2",) : ("code/SIZE.h", "code/darwin_plankton.F", "input")
    for entry in required
        ispath(joinpath(root, entry)) || error("The $(kind) checkout at $root is missing $entry")
    end
    return root
end

function _source_checkout(kind::Symbol, revision::AbstractString)
    url = _source_url(kind)
    isempty(strip(url)) && throw(ArgumentError("The Git URL for $kind cannot be empty."))
    # Include the URL so local development remotes can be tested without colliding
    # with the official upstream checkout at a given revision.
    key = bytes2hex(sha256(url))[1:16]
    parent = joinpath(Scratch.get_scratch!(@__MODULE__, "darwin-sources"), string(kind), key)
    mkpath(parent)
    destination = joinpath(parent, revision)

    FileWatching.Pidfile.mkpidlock(joinpath(parent, revision * ".lock"); stale_age=3600) do
        if isdir(destination)
            actual = strip(read(_git("-C", destination, "rev-parse", "HEAD"), String))
            actual == revision || error("Cached $kind source at $destination is at $actual, expected $revision. Remove this cache directory to re-fetch.")
            return _check_source(destination, kind)
        end

        staging = mktempdir(parent; prefix=".fetch-")
        try
            @info "Fetching $(kind) at $(revision)" url
            run(_git("init", "-q", staging))
            run(_git("-C", staging, "remote", "add", "origin", url))
            run(_git("-C", staging, "fetch", "--quiet", "--depth", "1", "origin", revision))
            run(_git("-C", staging, "checkout", "--quiet", "--detach", "FETCH_HEAD"))
            actual = strip(read(_git("-C", staging, "rev-parse", "HEAD"), String))
            actual == revision || error("Fetched $kind revision $actual rather than $revision")
            _check_source(staging, kind)
            mv(staging, destination)
        finally
            isdir(staging) && rm(staging; recursive=true, force=true)
        end
    end
    return destination
end

function _managed_darwin_root()
    return _source_checkout(:darwin, source_revisions().darwin)
end

function _managed_configuration_root()
    revisions = source_revisions()
    source = _source_checkout(:config, revisions.config)
    # A build or a source-edit helper can modify code/SIZE.h and darwin_plankton.F.
    # Keep the fetched Git checkout pristine, and stage a persistent writable copy.
    darwin = darwin_root()
    identity = string(darwin, '\n', revisions.darwin, '\n', source)
    key = bytes2hex(sha256(identity))[1:24]
    parent = joinpath(Scratch.get_scratch!(@__MODULE__, "darwin-workspaces"), key)
    mkpath(parent)
    destination = joinpath(parent, "dar_one_config")

    FileWatching.Pidfile.mkpidlock(joinpath(parent, "configuration.lock"); stale_age=3600) do
        if !isdir(destination)
            staging = mktempdir(parent; prefix=".config-")
            try
                cp(source, joinpath(staging, "dar_one_config"))
                _check_source(joinpath(staging, "dar_one_config"), :config)
                mv(joinpath(staging, "dar_one_config"), destination)
            finally
                isdir(staging) && rm(staging; recursive=true, force=true)
            end
        end
        _check_source(destination, :config)
        mkpath(joinpath(destination, "build"))
        mkpath(joinpath(destination, "run"))
    end
    return destination
end
