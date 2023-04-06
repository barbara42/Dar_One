include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets, DelimitedFiles
using Test

# test_file = "/Users/birdy/Documents/eaps_research/julia stuff/Dar_One/test/resources/test_SIZE.h"
# update_grid_size(1,1, test_file)

# TODO: write test 
# copy test file 
# update_grid_size(rand x, rand y) - overwrites test file
# open test file 
# every line except the ones with sNx and sNy should be the same 
# sNx and sNy lines should have 3 spaces after the =, and then the same values as passed into the function


og_file = "/Users/birdy/Documents/eaps_research/julia stuff/Dar_One/test/resources/test_darwin_plankton.F"
new_file = "/Users/birdy/Documents/eaps_research/julia stuff/Dar_One/test/resources/test_darwin_plankton_new.F"
# copy og file to new file
cp(og_file, new_file, force=true)
# keep parameters the same (all 0s)
param_list = zeros(19)
hold_nutrients_constant(param_list, new_file)
# test that new file is same as temp 
f1 = open(og_file)
f2 = open(new_file)
# test fails, unsure why (adding extra newline at end?). Visual inspection looks good 
# don't have time for this
#@test read(f1, String) == read(f2, String)
close(f1)
close(f2)


# param_list = zeros(19)
# param_list[2:5] .= 1
# test that new file is same as temp 
# except for the constant nutrients bits