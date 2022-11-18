include("../src/DarOneTools.jl")
using .DarOneTools
# other packages 
using ClimateModels
using NCDatasets

# the path to the Darwin version of the MITgcm
MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3" 

# unique name for your run 
config_id = "radtrans_test_10" # CHANGE ME

# create config object 
config_obj, rundir = create_MITgcm_config(config_id)

# Set up! Creating file structure and linking stuff
setup(config_obj)

# load seed files - these are from global darwin runs 
seed_file_3d = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/3d.nc"
seed_file_par = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/par.nc"
seed_file_temp = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/tave.nc"
seed_file_par = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/par.nc"

seed_ds_3d = Dataset(seed_file_3d)
seed_ds_par = Dataset(seed_file_par)
seed_ds_temp = Dataset(seed_file_temp)
seed_ds_par = Dataset(seed_file_par)

x = 203
y = 105
z = 1
t = 1

# length of run 
end_time = 2880 # one year, in iterations
update_end_time(config_obj, end_time)

# output frequency 
frequency = 2592000 # month 
update_all_diagnostic_freqs(config_obj, frequency)

# light 
update_radtrans(config_obj, seed_ds_par, x, y, z, t)

# temperature
new_temp = 30 # celius
update_temperature(config_obj, new_temp)
# update parameters 
# nutrients to keep constant: 1 (DIC), 18 (ALK), 19 (O2)
const_nuts = [1, 18, 19]
update_tracers(config_obj, const_nuts, seed_ds_3d, x, y, z, t, 1)

nutrients = 2:17 # not including 1 (DIC), 18 (ALK), 19 (O2)
pico = 21:24
cocco = 25:29
diaz = 30:34
diatom = 35:43
mixo_dino = 44:51
zoo = 52:67
bacteria = 68:70
update_tracers(config_obj, nutrients, seed_ds_3d, x, y, z, t)
update_tracers(config_obj, pico, seed_ds_3d, x, y, z, t)

# run model 
dar_one_run(config_obj)