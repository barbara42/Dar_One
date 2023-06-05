module DarOneTools

# using Dates, Printf, SparseArrays, Artifacts, LazyArtifacts, UUIDs, Suppressor
# using OrderedCollections, DataFrames, NetCDF, MeshArrays, ClimateModels

using OrderedCollections, Printf, Suppressor, ClimateModels, DelimitedFiles

include("Types.jl")
include("ReadFiles.jl")
include("ModelSteps.jl")
include("NamelistHelpers.jl")
include("GridBinHelpers.jl")

export MITgcm_path, base_configuration, filexe

# Types 
export MITgcm_config, MITgcm_namelist

# Build time modifiers
export update_grid_size, hold_nutrients_constant

# ReadFiles

# ModelSteps
export testreport, build, compile, setup, clean, MITgcm_launch

# NamelistHelpers
export update_param, update_tracers, update_tracer, update_temperature
export update_diagnostic_freq, update_all_diagnostic_freqs
export create_MITgcm_config, dar_one_run
export tracer_name_to_id, tracer_id_to_name
export update_end_time
# nutrient tracers 
export update_NO3, update_NO2, update_NH4, update_PO4, update_FeT, update_SiO2
export update_DOC, update_DON, update_DOP, update_DOFe, update_POC, update_PON, update_POP, update_POFe
export update_POSi, update_PIC, update_ALK, update_O2, update_CDOM
# biomass tracers
export update_pro, update_syn
export TRACER_IDS, SECONDS
export update_radtrans
export update_delX_delY_for_grid
export write_palat_matrix

# GridBinHelpers
export init_tracer_grid, init_temperature_grid, init_radtrans_grid, init_radtrans_grid_xy

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


"""
Functions to modify the build-time parameters (files in dar_one_config > code)
NOTE: dangerous! no copies of files are made
"""

"""
Default grid size is 1 x 1. 

"""
function update_grid_size(x, y, file=joinpath(MITgcm_path[1], "verification", base_configuration, "code", "SIZE.h"))
    meta = read(file, String)
    meta = split(meta, "\n")
    
    # find the first parameter line index = p_idx
    p_idx = findall(x->occursin("PARAMETER",x), meta)[1]
    
    # get the lines at sNx and sNy are defined (1st two in the param list)
    x_line = meta[p_idx+1]
    y_line = meta[p_idx+2]
    i = findfirst("=", x_line)
    
    # get only the value - print? 
    current_x_val = replace(x_line, r"[^0-9]" => "")
    current_y_val = replace(y_line, r"[^0-9]" => "")
    
    new_x = x
    new_y = y
    # 3 spaces after = is convention for this file
    new_x_line = x_line[1:i[1]] * "   " * string(new_x) * ","
    new_y_line = y_line[1:i[1]] * "   " * string(new_y) * "," 
    
    meta[p_idx+1] = new_x_line 
    meta[p_idx+2] = new_y_line
    
    # write over file with new values
    writedlm(file, meta)  
end

"""
hold_nutrients_constant(param_list)

Takes a vector of length 19, for each of the non-plankton tracers, with values of either 0 or 1.
This function modifies darwin_plankton.F, and mulitplies the computed tendencies of the nutrient tracers by the value passed in.
    0 = hold constant 
    1 = allow change 

The appropriate vector to pass in to hold all nutrients constant would be `zeros(19)`.
To allow all nutrients to vary, the parameter would be `ones(19)`.
The indices in the param_list correspond to the following nutrients, in order: 
[DIC, NO3, NO2, NH4, PO4, SiO2, FeT, DOC, DON, DOP, DOFe, PIC, POC, PON, PIP, PISi, POFe, ALK, O2]
"""
function hold_nutrients_constant(param_list, file=joinpath(MITgcm_path[1], "verification", base_configuration, "code", "darwin_plankton.F"))
    # TODO: add check that para is 19 long 
    meta = read(file, String)
    meta = split(meta, "\n")
    p_idx = findall(x->occursin("DAR1",x), meta)[1]
    for i in 1:19
        line = meta[p_idx+i]
        l = findfirst("*", line)[1]
        new_line = line[1:l]*string(param_list[i])
        meta[p_idx+i] = new_line
    end
    # write over file with new values
    writedlm(file, meta, quotes=false)
end

end # module
