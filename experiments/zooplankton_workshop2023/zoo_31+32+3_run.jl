include("../../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets
using DelimitedFiles

# set path to MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# create and set up config 
# TODO: Change name! Must be unique!
config_name = "zoo32_test" 
config_obj, rundir = create_MITgcm_config(config_name)
setup(config_obj)

# length of run 
end_time = 2880*1 # 2880 = one year, in iterations
update_end_time(config_obj, end_time)

# output frequency 
frequency = 2592000 # 2592000 = one month, in seconds
update_all_diagnostic_freqs(config_obj, frequency)

# seed files from Darwin - yearly averages
seed_file = "/dar_one_docker/3d.nc"
seed_ds = Dataset(seed_file)
seed_par_file = "/dar_one_docker/par.nc"
seed_ds_par = Dataset(seed_par_file)
# seeded from N Pacific gyre 
# OPTION: try different locations! (change x and y)
x = 203
y = 135
z= 1
t = 1 # using yearly averages 

# PLANKTON COMMUNITY
# populating initial abundances with values from Darwin
# OPTION: try different abundances 
tracer_ids = []
values = []
for tracer_id in 21:70
    tracer_name = tracer_id_to_name(tracer_id)
    append!(tracer_ids, tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    append!(values, val)
end
update_tracers(config_obj, tracer_ids, values)

# use zoo values to populate new 16 types of zoo 
for tracer_id in 52:67
    tracer_name = tracer_id_to_name(tracer_id)
    append!(tracer_ids, tracer_id+16)
    val = seed_ds[tracer_name][x, y, z, t]
    append!(values, val)
end
update_tracers(config_obj, tracer_ids, values)

# NUTRIENTS
# populating initial abundances with values from Darwin
# OPTION: try different nutrient values 
tracer_ids = []
values = []
for tracer_id in 1:20
    tracer_name = tracer_id_to_name(tracer_id)
    append!(tracer_ids, tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    append!(values, val)
end
update_tracers(config_obj, tracer_ids, values)

# OPTION: change light levels
# z=3 # lower value for light - farther into the water column
# update_radtrans(config_obj, seed_ds_par, x, y, z, t)

# OPTION: change temperature 
# - default temp is 20C
# new_temp = 30 
# update_temperature(config_obj, new_temp)

# OPTION: try different palatability matrices 
# load up matrices from file 
# default values (also in file1)
# - zoo TRAC52-TRAC67 have 1:10 feeding size preference (prey:pred)
# - zoo TRAC68-TRAC83 have 1:3 feeding size pref 

# file1 = "/dar_one_docker/Dar_One/experiments/zooplankton_workshop2023/extras/zoo32_PALAT.csv"
# palat1 = readdlm(file1, ',', Float64)

# - zoo TRAC68-TRAC83 have 1:30 feeding size pref
# file2 = "/dar_one_docker/Dar_One/experiments/zooplankton_workshop2023/extras/zoo32_PALAT_1_30.csv"
# palat_thirtieth = readdlm(file12 ',', Float64)

# - zoo TRAC68-TRAC83 have 2:1 feeding size pref (ish)
# file3 = "/dar_one_docker/Dar_One/experiments/zooplankton_workshop2023/extras/zoo32_PALAT_2_1.csv"
# palat_double = readdlm(file12 ',', Float64)

# TODO: uncomment and put which palat matrix you want to use
# palat_matrix = palat1
# write_palat_matrix(config_obj, strict_palat_matrix)

# FINALLY! Run! 
dar_one_run(config_obj)
