
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

##################
# set everything up 
##################

# the path to the Darwin version of the MITgcm
MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3" 
#MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# unique name for your run 
config_id = "beginner_tutorial" # CHANGE ME

# create config object 
config_obj, rundir = create_MITgcm_config(config_id)

# Set up! Creating file structure and linking stuff
setup(config_obj)

##################
# Modify runtime parameters 
##################

# length of run 
end_time = 2880 # one year, in iterations
update_end_time(config_obj, end_time)

# temperature
new_temp = 30 # celius
update_temperature(config_obj, new_temp)

# nutrients (mmol per m^3)
# NO3
new_NO3_val = 2.0
update_NO3(config_obj, new_NO3_val)
#PO4
new_PO4_val = 0.1
update_PO4(config_obj, new_PO4_val)
# FeT
new_FeT_val = 1e-3
update_FeT(config_obj, new_FeT_val)

# Prochlorococcus (mmol per m^3)
pro_val = 1e-3
update_pro(config_obj, pro_val)

##################
# run model
##################
dar_one_run(config_obj)