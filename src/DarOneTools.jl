module DarOneTools

# using Dates, Printf, SparseArrays, Artifacts, LazyArtifacts, UUIDs, Suppressor
# using OrderedCollections, DataFrames, NetCDF, MeshArrays, ClimateModels

using OrderedCollections, Printf, Suppressor, ClimateModels

include("Types.jl")
include("ReadFiles.jl")
include("ModelSteps.jl")
include("NamelistHelpers.jl")
include("GridBinHelpers.jl")

export MITgcm_path, base_configuration, filexe

# Types 
export MITgcm_config, MITgcm_namelist

# ReadFiles

# ModelSteps
export testreport, build, compile, setup, clean, MITgcm_launch

# NamelistHelpers
export update_param, update_tracers, update_tracer, update_temperature
export update_diagnostic_freq, update_all_diagnostic_freqs
export create_MITgcm_config, dar_one_run
export tracer_name_to_id, tracer_id_to_name
export update_end_time, update_PO4, update_NO3, update_FeT, update_pro, update_syn
export TRACER_IDS, SECONDS
export update_radtrans
export update_delX_delY_for_grid

# GridBinHelpers
export init_tracer_grid, init_temperature_grid, init_radtrans_grid

#export pause, stop, clock, monitor, train, help
export verification_experiments, read_namelist, write_namelist
export read_mdsio, read_meta, read_available_diagnostics
export scan_rundir, scan_stdout
# export read_bin, read_flt, read_mnc, read_nctiles, findtiles
# export GridLoad_mnc, GridLoad_mdsio
# export cube2compact, compact2cube, convert2array, convert2gcmfaces
# export SeaWaterDensity, MixedLayerDepth


"""
    MITgcm_path

Path to a MITgcm folder. `MITgcm_path[1]` should generally be used. `MITgcm_path[2]` is mostly 
meant to facilitate comparisons between e.g. MITgcm releases when needed.
"""
MITgcm_path = ["/Users/birdy/Documents/eaps_research/darwin3"]

"""
    base_configuration

Name of the folder that lives in the /verificaion folder of the MITgcm. This holds the basic 
configuration for Dar_One, which is a homogenous 1m x 1m x 1m water parcel with air/sea exchange, 
no mixing, few nuturients, and no biological forcing. 
"""
base_configuration = "dar_one_config"

"""
    filexe

Path to the file that contains the built MITgcm, normally named "mitgcmuv".
The executable should be compiled on whatever machine you're using to run the model, 
unless using the docker container [TODO: link]
"""
filexe=joinpath(MITgcm_path[1],"verification",base_configuration,"build","mitgcmuv")

end # module
