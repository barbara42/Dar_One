include("../src/DarOneTools.jl")
using .DarOneTools
# other packages 
using ClimateModels
using NCDatasets

# the path to the Darwin version of the MITgcm
MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3" 

nX = 1
nY = 1

# update SIZE.h 
update_grid_size(nX, nY)

# which nutrients can change?
param_list = ones(19) # let all nutrients cycle normally
hold_nutrients_constant(param_list)

build(base_configuration)