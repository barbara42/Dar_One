include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set path to MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# set up size of your grid
# running the 360x160 world in 16 quadrants in case something goes wrong midway
nX = 90
nY = 40

# update SIZE.h 
update_grid_size(nX, nY)

# which nutrients can change?
param_list = ones(19) # let all nutrients cycle normally
hold_nutrients_constant(param_list)

# BUILD 
build(base_configuration)