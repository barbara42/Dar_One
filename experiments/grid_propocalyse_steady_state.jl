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

# model was compiled with a grid size of 30x30
n_steps = 2 

# note: these values are INDICES not values 
depth = 1
lon = 203
# lats = [round(x) for x in LinRange(105,130,n_steps)]
# times = [round(x) for x in LinRange(1,52,n_steps)]
lats=[105,130]
times=[1,30]

nutrients = 1:19 
pico = 21:24
cocco = 25:29
#diaz = 30:34
diatom = 35:43
mixo_dino = 44:51
zoo = 52:67
bacteria = 68:70

ptracers = vcat(nutrients, pico, cocco, diatom, mixo_dino, zoo, bacteria)

# # unique name for your run 
# config_id = "grid_test" # CHANGE ME
# config_obj, rundir = create_MITgcm_config(config_id)
# setup(config_obj)
# mkdir("$rundir/bin_files")

# for tracer_id in ptracers
#     # - create bin file from seed_ds 
#     # - update PTRACERS_initialFile to point to that bin file 
#     tracer_name = tracer_id_to_name(tracer_id)
#     println(tracer_name)
data = Matrix{Float32}(undef,2,2)
for (i,lat) in enumerate(lats)
    for (t,time) in enumerate(times)
        data[i,t] = seed_ds_3d["TRAC21"][lon, lat, depth, time]
    end
end
#     println(data)
#     write("$rundir/bin_files/$tracer_name.bin", data)
# end 
# TODO: if radtrans still a constant, will it use that value for each grid? 



# # length of run 
# end_time = 2880*1 # one year, in iterations
# update_end_time(config_obj, end_time)

# # output frequency 
# frequency = 2592000
# update_all_diagnostic_freqs(config_obj, frequency)

# # FUTURE:
# # create bin file for temperature
# # create bin files for each tracer

# # for now, just a place holder 
# # going to manually add in another value in the file for Pro and Syn 
# update_tracers(config_obj, [21,22], seed_ds_3d, lon, lats[1], depth, times[1])

# nutrients = 1:19 
# update_tracers(config_obj, nutrients, seed_ds_3d, lon, lats[1], depth, times[1])


# # dar_one_run(config_obj)

