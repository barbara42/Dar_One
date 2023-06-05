include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set path to MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# set up size of your grid 
nX = 1
nY = 1

# # update SIZE.h 
# update_grid_size(nX, nY)

# # which nutrients can change?
# param_list = zeros(19) # hold everything constant 
# hold_nutrients_constant(param_list)

# # BUILD 
# build(base_configuration)



# create and set up config 
config_name = "test_pro"
config_obj, rundir = create_MITgcm_config(config_name)
setup(config_obj)

# length of run 
end_time = 2880*1 # 2880 = one year, in iterations
update_end_time(config_obj, end_time)

# output frequency 
frequency = 2592000
update_all_diagnostic_freqs(config_obj, frequency)

# update data > PARM04 > delX and delX
update_delX_delY_for_grid(config_obj, nX, nY) 



# seeded from N Pacific gyre 
seed_file = "/dar_one_docker/3d.nc"
seed_ds = Dataset(seed_file)
seed_par_file = "/dar_one_docker/par.nc"
seed_ds_par = Dataset(seed_par_file)
x = 203
y = 135
z= 1
t = 1 # using yearly averages 


# NUTRIENTS
# set NO3 to 0 
# set NH4 to 0 
# other nutrient - same (high iron)
# set PO4 to .83 
tracer_ids = []
values = []
for tracer_id in 1:20
    tracer_name = tracer_id_to_name(tracer_id)
    append!(tracer_ids, tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    append!(values, val)
    # init_tracer_grid(config_obj, tracer_name, init_list, dim, (nX,nY))
end
update_tracers(config_obj, tracer_ids, values)

# COMMUNITY
# same 
# start with the same plankton community in each cell 
tracer_ids = []
values = []
for tracer_id in 21:70
    tracer_name = tracer_id_to_name(tracer_id)
    append!(tracer_ids, tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    # everything except pro and grazers is 0 
    if (tracer_id > 21 && tracer_id < 52) || tracer_id >= 68
        val = 0.0
    end
    append!(values, val)
end
update_tracers(config_obj, tracer_ids, values)


z=3 # lower value for light - farther into the water column
update_radtrans(config_obj, seed_ds_par, x, y, z, t)

# FINALLY! Run! 
dar_one_run(config_obj)
