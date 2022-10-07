
include("../src/DarOneTools.jl")
using .DarOneTools

MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3" # CHANGE ME 

# create config
config_name = base_configuration
config_id = "tutorial_test_9"
folder = joinpath(MITgcm_path[1], "verification", config_name, "run")
config_obj = MITgcm_config(configuration=config_name, ID=config_id, folder=folder)

# setup 
filexe=joinpath(MITgcm_path[1],"verification",config_name,"build","mitgcmuv")

# TODO: build model here instead of using a pre-built exec
# check for mitgcmuv executable, if not there, build it
# ... the `make -j 4` command in ModelSteps>build fails :'(  
# even though it works fine when i run the commands from the CL
# WORKAROUND: run the folling from the build dir
# ../../../tools/genmake2 -mods=../code
# make depend
# make -j 4
if !isfile(filexe)
	println("building...")
	build(config_obj)
	println("done with build")
end

println("MITgcm_path[1]: ", MITgcm_path[1])
println("running setup...")
setup(config_obj)
println("done with setup")
# NOTE: creates a new folder each time it runs, so CLEAN OUT EVENTUALLY


println(config_obj)
println("********************************************************")
println("* Config ID: ", config_id, " ***** copy this into darwin-run.jl *****")
println("********************************************************")