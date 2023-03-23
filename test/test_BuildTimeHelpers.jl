include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets, DelimitedFiles

test_file = "/Users/birdy/Documents/eaps_research/julia stuff/Dar_One/test/resources/test_SIZE.h"
update_grid_size(1,1, test_file)

# TODO: write test 
# copy test file 
# update_grid_size(rand x, rand y) - overwrites test file
# open test file 
# every line except the ones with sNx and sNy should be the same 
# sNx and sNy lines should have 3 spaces after the =, and then the same values as passed into the function

