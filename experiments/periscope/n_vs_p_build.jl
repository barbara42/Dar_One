include("../../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set path to MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# set up size of your grid 
nX = 10
nY = 10

# update SIZE.h 
update_grid_size(nX, nY)

# which nutrients can change?
param_list = ones(19) # allow everything to change 
hold_nutrients_constant(param_list)

# BUILD 
build(base_configuration)