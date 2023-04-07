include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set path to MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# set up size of your grid 
nX = 30
nY = 30

# # update SIZE.h 
# update_grid_size(nX, nY)

# # which nutrients can change?
# param_list = zeros(19) # hold everything constant 
# hold_nutrients_constant(param_list)

# # BUILD 
# build(base_configuration)



# create and set up config 
config_name = "n_fixers_1"
config_obj, rundir = create_MITgcm_config(config_name)
setup(config_obj)

# length of run 
end_time = 2880*5 # 2880 = one year, in iterations
update_end_time(config_obj, end_time)

# output frequency 
frequency = 2592000*12
update_all_diagnostic_freqs(config_obj, frequency)

# update data > PARM04 > delX and delX
update_delX_delY_for_grid(config_obj, nX, nY) 

# seeded from N Pacific gyre 
seed_file = "/dar_one_docker/3d.nc"
seed_ds = Dataset(seed_file)
seed_par_file = "/dar_one_docker/par.nc"
seed_ds_par = Dataset(seed_par_file)
x = 203
y = 105
z= 1
t = 1 # using yearly averages 

# start with the same plankton community in each cell 
for tracer_id in 21:70
    tracer_name = tracer_id_to_name(tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    init_list = repeat([val], nX)
    dim = "x"
    init_tracer_grid(config_obj, tracer_name, init_list, dim, (nX,nY))
end

# start with the same nutrients in each cell 
for tracer_id in 1:20
    # skip no3 and po4 (2 and 5)
    if tracer_id == 2 || tracer_id == 5
        continue
    end
    tracer_name = tracer_id_to_name(tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    init_list = repeat([val], nX)
    dim = "x"
    init_tracer_grid(config_obj, tracer_name, init_list, dim, (nX,nY))
end

# set increasing nitrate availability along x axis 
multipliers = LinRange(0,10, nX)
tracer_name = tracer_id_to_name(2)
val = seed_ds[tracer_name][x, y, z, t]
init_list = repeat([val], nX) .* multipliers
# set manually 
init_list = LinRange(0,48, nX)
dim = "x"
init_tracer_grid(config_obj, tracer_name, init_list, dim, (nX,nY))

# set increasing phosphate along y axis 
multipliers = LinRange(0,10, nX)
tracer_name = tracer_id_to_name(5)
val = seed_ds[tracer_name][x, y, z, t]
init_list = repeat([val], nY) .* multipliers
# set manually 
init_list = LinRange(0,3, nX)
dim = "y"
init_tracer_grid(config_obj, tracer_name, init_list, dim, (nX,nY))

z=3 # lower value for light - farther into the water column
update_radtrans(config_obj, seed_ds_par, x, y, z, t)

# FINALLY! Run! 
dar_one_run(config_obj)
