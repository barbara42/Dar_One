module DarOneTools

# using Dates, Printf, SparseArrays, Artifacts, LazyArtifacts, UUIDs, Suppressor
# using OrderedCollections, DataFrames, NetCDF, MeshArrays, ClimateModels

using OrderedCollections, Printf, Suppressor, ClimateModels

include("Types.jl")
include("ReadFiles.jl")
include("ModelSteps.jl")
include("NamelistHelpers.jl")

# Types 

# ReadFiles

# ModelSteps

# NamelistHelpers
export update_param, create_MITgcm_config

export MITgcm_path, base_configuration, filexe
export MITgcm_config, MITgcm_namelist, MITgcm_launch
export testreport, build, compile, setup, clean
#export pause, stop, clock, monitor, train, help
export verification_experiments, read_namelist, write_namelist
export read_mdsio, read_meta, read_available_diagnostics
export scan_rundir, scan_stdout
# export read_bin, read_flt, read_mnc, read_nctiles, findtiles
# export GridLoad_mnc, GridLoad_mdsio
# export cube2compact, compact2cube, convert2array, convert2gcmfaces
# export SeaWaterDensity, MixedLayerDepth

# p=dirname(pathof(DarOneTools))

# artifact_toml = joinpath(p, "../Artifacts.toml")
# MITgcm_hash = artifact_hash("MITgcm", artifact_toml)

"""
    MITgcm_path

Path to a MITgcm folder. `MITgcm_path[1]` should generally be used. `MITgcm_path[2]` is mostly 
meant to facilitate comparisons between e.g. MITgcm releases when needed.
"""


MITgcm_path = ["/Users/birdy/Documents/eaps_research/darwin3"]
base_configuration = "dar_one_config"
filexe=joinpath(MITgcm_path[1],"verification",base_configuration,"build","mitgcmuv")

end # module
