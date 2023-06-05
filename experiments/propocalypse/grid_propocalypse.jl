include("../../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set up size of your grid 

nX = 52
nY = 37

# update SIZE.h 
# BUILD 

# load seed files - these are from global darwin runs 
seed_file_3d = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/3d.nc"
seed_file_temp = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/tave.nc"
seed_file_par = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/par.nc"
seed_ds_3d = Dataset(seed_file_3d)
seed_ds_temp = Dataset(seed_file_temp)
seed_ds_par = Dataset(seed_file_par)

# what slice do we want?
# these are INDICES so must be INTEGERS
z = 1
x = 206
y_range = collect(101:137)
t_range = collect(1:52)

# create and set up config 
config_name = "gp-hires-time"
config_obj, rundir = create_MITgcm_config(config_name)
setup(config_obj)

# length of run 
end_time = 2880*20 # 2880 is one year, in iterations
update_end_time(config_obj, end_time)

# output frequency 
frequency = 2592000 # monthly 
update_all_diagnostic_freqs(config_obj, frequency)

# update data > PARM04 > delX and delX
update_delX_delY_for_grid(config_obj, nX, nY) 

# create initial bin files for tracers that are not zero
non_zero_tracers = cat(1:29, 35:70, dims=1)
for tracer_id in non_zero_tracers
    tracer_name = tracer_id_to_name(tracer_id)
    init_matrix = seed_ds_3d[tracer_name][x, y_range, z, t_range]
    init_tracer_grid(config_obj, tracer_name, transpose(init_matrix))
end

# create initial bin files for tracers that are zero (diazotrophs)
for tracer_id in [30,31,32,33,34]
    tracer_name = tracer_id_to_name(tracer_id)
    init_matrix = zeros(Float32, nY, nX)
    init_tracer_grid(config_obj, tracer_name, transpose(init_matrix))
end

# create bin file for temperatures - all 15 degrees
# temp_matrix = zeros(Float32, nY, nX)
# temperature = 10
# fill!(temp_matrix, temperature)
temp_matrix = seed_ds_temp["Ttave"][x, y_range, z, t_range]
init_temperature_grid(config_obj, transpose(temp_matrix))

# create bin files for light 
z=3 # lower value for light - farther into the water column
init_radtrans_grid(config_obj, seed_ds_par, x, y_range, z, t_range)

# FINALLY! Run! 
dar_one_run(config_obj)
