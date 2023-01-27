include("../src/DarOneTools.jl")
using .DarOneTools
# other packages 
using ClimateModels
using NCDatasets

# the path to the Darwin version of the MITgcm
MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3" 

# load seed files - these are from global darwin runs 
seed_file_3d = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/3d.nc"
seed_file_temp = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/tave.nc"
seed_file_par = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/par.nc"
seed_ds_3d = Dataset(seed_file_3d)
seed_ds_temp = Dataset(seed_file_temp)
seed_ds_par = Dataset(seed_file_par)


# runs are seeded with temperature, nutrients, and biomass values 
# from a fixed longitude, along a latitude range of 25-55, over the
# course of the year 

# note: these values are INDICES not values 
depth = 1
lon = 203
lats = range(105, 130, step=2)
times = range(1, 52, step=4)
# lat_range = LinRange(25, 55, n_steps)
# time_range = LinRange(25, 55, n_steps)

for lat in lats
    for t in times
        # unique name for your run 
        config_id = "long-RADTRANS-propocalypse-$lat-$t" # CHANGE ME
        config_obj, rundir = create_MITgcm_config(config_id)
        setup(config_obj)

        # length of run 
        end_time = 2880*15 # one year, in iterations
        update_end_time(config_obj, end_time)

        # output frequency 
        frequency = 2592000*12*3
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

        dar_one_run(config_obj)
    end
end



