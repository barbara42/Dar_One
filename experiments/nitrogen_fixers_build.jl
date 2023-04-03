include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set up size of your grid 
nX = 30
nY = 30

# update SIZE.h 
update_grid_size(nX, nY)

# which nutrients can change?
param_list = zeros(19) # hold everything constant 
hold_nutrients_constant(param_list)

# BUILD 
build(base_configuration)