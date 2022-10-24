
include("../src/DarOneTools.jl")
using .DarOneTools

# other packages 
using ClimateModels

# runing a simulation actually takes two steps 
# - setup 
# - run 
# In the "setup" step, you choose a name for your experiment and it creates 
# all the necessary input and output folders, and symlinks to the darwin model. 
# These input folders are where modified parameter files are going to to written. 
# The output will be in a folder called "ecco_gud_DATE_0001" where 
# DATE is the day you initialized the run


# the path to the Darwin version of the MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# unique name for your run 
config_id = "docker_test" # CHANGE ME

# reload the config 
# TODO: create method, put in helpers 
# config_name = base_configuration
# folder = joinpath(MITgcm_path[1], "verification/$(config_name)/run")
# config_obj = MITgcm_config(configuration=config_name, ID=config_id, folder=folder)
# rundir = joinpath(folder, config_id, "run")

config_obj, rundir = create_MITgcm_config(config_id)

# Set up! Creating file structure and linking stuff
setup(config_obj)

##################
# Modify runtime parameters here
# file > group > parameter
##################

# timing 
update_param("data", "PARM03", "nenditer", 2880, config_obj) # end after 1 year

# temperature
update_param("data", "PARM01", "tRef", 30.0, config_obj)

# nutrients 
# NO3
update_param("data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :, 2)", 2, config_obj)
#PO4
update_param("data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :, 5)", 0.1, config_obj)
# FeT
update_param("data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :, 6)", 1e-3, config_obj)

# Prochlorococcus
update_param("data.ptracers", "PTRACERS_PARM01", "PTRACERS_ref( :,21)", 1e-3, config_obj)

##################
# run model
##################
println("launching...")
t = @elapsed begin
    MITgcm_launch(config_obj)
end
println("run completed")
println("time elapse: ", t, " seconds")