"""
    darwin_root()

Resolve the Darwin3 source directory. `DARONE_MITGCM_PATH` takes precedence over
`MITgcm_path[1]`, which remains supported for existing scripts. Cycle 1 resolves
existing checkouts; downloading sources will be added in the next cycle.
"""
function darwin_root()
    path = get(ENV, "DARONE_MITGCM_PATH", MITgcm_path[1])
    isempty(strip(path)) && throw(ArgumentError("Darwin3 path is empty; set DARONE_MITGCM_PATH or MITgcm_path[1]."))
    return abspath(expanduser(path))
end

"""
    configuration_root(name=base_configuration)

Resolve a verification configuration directory. Set `DARONE_CONFIG_PATH` to use
`dar_one_config` from an independent checkout, without placing it under
`darwin3/verification`. Other MITgcm verification configurations continue to be
resolved relative to Darwin3.
"""
function configuration_root(name::AbstractString=base_configuration)
    isempty(strip(name)) && throw(ArgumentError("Configuration name cannot be empty."))
    if name == base_configuration && haskey(ENV, "DARONE_CONFIG_PATH")
        path = ENV["DARONE_CONFIG_PATH"]
        isempty(strip(path)) && throw(ArgumentError("DARONE_CONFIG_PATH cannot be empty."))
        return abspath(expanduser(path))
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
