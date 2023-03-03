include("../src/DarOneTools.jl")
using .DarOneTools
# other packages 
using ClimateModels
using NCDatasets

# the path to the Darwin version of the MITgcm
MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3" 

#build(base_configuration)

# load seed files - these are from global darwin runs 
seed_file_3d = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/3d.nc"
seed_file_temp = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/tave.nc"
seed_file_par = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/par.nc"
seed_ds_3d = Dataset(seed_file_3d)
seed_ds_temp = Dataset(seed_file_temp)
seed_ds_par = Dataset(seed_file_par)

# note: these are INDICES not values 
depth = 1
# # hawaii ish 
# lon = 203
# lat = 105

lon = 203
lat = 109
t = 1

descriptions = ["control", "with-no3", "with-nh4"]
for i in 1:3
    # unique name for your run 
    config_id = "bottle-$(descriptions[i])-$lon-$lat" # CHANGE ME
    config_obj, rundir = create_MITgcm_config(config_id)
    setup(config_obj)

    # length of run 
    end_time = 56 # 2880 = one year, in iterations
    update_end_time(config_obj, end_time)

    # output frequency 
    frequency = 43200/3 # 604800 = one week, in seconds; 43200 = 12 hours 
    update_all_diagnostic_freqs(config_obj, frequency)

    # set temperature from seed file 
    temp = seed_ds_temp["Ttave"][lon, lat, depth, t]
    update_temperature(config_obj, temp)

    # light 
    light_depth = 4 # 45m
    update_radtrans(config_obj, seed_ds_par, lon, lat, light_depth, t)

    # set nutrients and biomass from seed file 
    nutrients = 1:19 
    pico = 21:24
    cocco = 25:29
    diaz = 30:34
    diatom = 35:43
    mixo_dino = 44:51
    zoo = 52:67
    bacteria = 68:70
    update_tracers(config_obj, nutrients, seed_ds_3d, lon, lat, depth, t)
    update_tracers(config_obj, pico, seed_ds_3d, lon, lat, depth, t)
    update_tracers(config_obj, cocco, seed_ds_3d, lon, lat, depth, t)
    update_tracers(config_obj, diatom, seed_ds_3d, lon, lat, depth, t)
    update_tracers(config_obj, mixo_dino, seed_ds_3d, lon, lat, depth, t)
    update_tracers(config_obj, zoo, seed_ds_3d, lon, lat, depth, t)
    update_tracers(config_obj, bacteria, seed_ds_3d, lon, lat, depth, t)

    if i == 2
        # add extra NO3
        println("ADDING no3!!!!!!!!!!")
        original_no3_val = seed_ds_3d["TRAC02"][lon, lat, depth, t]
        new_no3_val = original_no3_val*10
        update_tracer(config_obj, 2, new_no3_val)
    end
    if i == 3
        println("ADDING nh4!!!!!!!!!!")
        # add extra NH4 
        original_no3_val = seed_ds_3d["TRAC04"][lon, lat, depth, t]
        new_no3_val = original_no3_val*10
        update_tracer(config_obj, 4, new_no3_val)
    end
    dar_one_run(config_obj)


end


