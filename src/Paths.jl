"""
    darwin_root()

Resolve the Darwin3 source directory. `DARONE_MITGCM_PATH` takes precedence over
legacy `MITgcm_path[1]`. Without an existing explicit checkout, download/cache
the pinned Darwin3 revision automatically (see `source_revisions()`).
"""
function darwin_root()
    if haskey(ENV, "DARONE_MITGCM_PATH")
        path = ENV["DARONE_MITGCM_PATH"]
        isempty(strip(path)) && throw(ArgumentError("DARONE_MITGCM_PATH cannot be empty."))
        return abspath(expanduser(path))
    end
    path = MITgcm_path[1]
    isempty(strip(path)) && throw(ArgumentError("MITgcm_path[1] cannot be empty."))
    # The historical Docker default is not a user-configured checkout. On a
    # normal machine, fall back to the managed Darwin3 sources instead.
    if path == _LEGACY_DOCKER_ROOT &&
       (!isdir(path) || haskey(ENV, "DARONE_DARWIN_REV") || haskey(ENV, "DARWIN_REV"))
        return _managed_darwin_root()
    end
    return abspath(expanduser(path))
end

"""
    configuration_root(name=base_configuration)

Resolve the verification configuration. `DARONE_CONFIG_PATH` selects a local
checkout. An existing nested Darwin3 verification configuration remains usable;
otherwise the pinned `dar_one_config` revision is staged in a writable cache.
"""
function configuration_root(name::AbstractString=base_configuration)
    isempty(strip(name)) && throw(ArgumentError("Configuration name cannot be empty."))
    if name == base_configuration
        if haskey(ENV, "DARONE_CONFIG_PATH")
            path = ENV["DARONE_CONFIG_PATH"]
            isempty(strip(path)) && throw(ArgumentError("DARONE_CONFIG_PATH cannot be empty."))
            return abspath(expanduser(path))
        end
        nested = joinpath(darwin_root(), "verification", name)
        (isdir(nested) && !haskey(ENV, "DARONE_CONFIG_REV")) && return nested
        return _managed_configuration_root()
    end
    return joinpath(darwin_root(), "verification", name)
end

build_directory(name::AbstractString=base_configuration) = joinpath(configuration_root(name), "build")
input_directory(name::AbstractString=base_configuration) = joinpath(configuration_root(name), "input")
run_directory(name::AbstractString=base_configuration) = joinpath(configuration_root(name), "run")
executable_path(name::AbstractString=base_configuration) = joinpath(build_directory(name), "mitgcmuv")

# Input scripts historically assume that '../' points at the configuration and
# '../../' points at Darwin3's verification directory. Preserve those logical
# meanings even when the configuration itself is checked out elsewhere.
function _expand_input_paths(content::AbstractString, name::AbstractString)
    verification = joinpath(darwin_root(), "verification") * "/"
    configuration = configuration_root(name) * "/"
    return replace(replace(content, "../../" => verification), "../" => configuration)
end
