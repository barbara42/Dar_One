include("../src/DarOneTools.jl")
using .DarOneTools

MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3/" # CHANGE ME 

# you should only have to build once, and then be good to go! 
build(base_configuration)

# very basic setup and run to test the executable 
# (if this doesn't work, see "troubleshooting")