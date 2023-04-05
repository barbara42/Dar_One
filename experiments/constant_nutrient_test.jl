include("../src/DarOneTools.jl")
using .DarOneTools
# other packages 
using ClimateModels


# path to local Darwin version of the MITgcm
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# set nutrients constant 
hold_nutrients_constant(zeros(19))

build(base_configuration)

# unique name for your run 
config_id = "constant_nutrient_test_1" # CHANGE ME

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

# output frequency 
frequency = 2592000 # monthly 
update_all_diagnostic_freqs(config_obj, frequency)

# temperature
new_temp = 20 # celius
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
update_syn(config_obj, pro_val)

##################
# run model
##################
dar_one_run(config_obj)