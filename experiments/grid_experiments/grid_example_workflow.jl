include("../../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set up size of your grid 

nX = 30
nY = 30

# update SIZE.h 
# BUILD 

# load a seed file
seed_file = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/jan_7_2022/3d.0000000000.nc"
seed_ds = Dataset(seed_file)
seed_file_par = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/par.nc"
seed_ds_par = Dataset(seed_file_par)

x = 203
y = 105
z= 1
t = 40 # AUG

# create and set up config 
config_name = "high-light"
config_obj, rundir = create_MITgcm_config(config_name)
setup(config_obj)

# length of run 
end_time = 2880*15 # one year, in iterations
update_end_time(config_obj, end_time)

# output frequency 
frequency = 2592000*12*3
update_all_diagnostic_freqs(config_obj, frequency)

# update data > PARM04 > delX and delX
update_delX_delY_for_grid(config_obj, nX, nY) 

# create initial bin files for tracers that stay constant across entire grid
for tracer_id in [1, 18, 19]
    tracer_name = tracer_id_to_name(tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    init_list = repeat([val], nX)
    dim = "x"
    init_tracer_grid(config_obj, tracer_name, init_list, dim, (30,30))
end

# create initial bin files for tracers that are zero
for tracer_id in [20,30,31,32,33,34]
    tracer_name = tracer_id_to_name(tracer_id)
    init_list = repeat([0], nX)
    dim = "x"
    init_tracer_grid(config_obj, tracer_name, init_list, dim, (30,30))
end

# create initial bin files for tracers that are multiplied
# and set the namelist params to point to bin files 
changing_tracers = cat(2:17, 21:29, 35:70, dims=1)
multipliers = LinRange(0, 20, nX)
for tracer_id in changing_tracers
    tracer_name = tracer_id_to_name(tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    init_list = repeat([val], nX) .* multipliers
    dim = "x"
    init_tracer_grid(config_obj, tracer_name, init_list, dim, (30,30))
end

# create bin file for initial temperatures 
temp_list = LinRange(0,30,nY)
dim="y"
init_temperature_grid(config_obj, temp_list, dim, (30,30))

t = 30 #june
update_radtrans(config_obj, seed_ds_par, x, y, z, t)
# FINALLY! Run! 
dar_one_run(config_obj)
