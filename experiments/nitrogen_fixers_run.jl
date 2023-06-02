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
config_name = "n_30x30"
config_obj, rundir = create_MITgcm_config(config_name)
setup(config_obj)

# length of run 
end_time = 2880 * 5 # 2880 = one year, in iterations
update_end_time(config_obj, end_time)

# output frequency 
frequency = 2592000*12 # 2592000 = one month, in seconds
update_all_diagnostic_freqs(config_obj, frequency)

new_temp = 24
update_temperature(config_obj, new_temp)

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

# start with the same plankton community in each cell 
for tracer_id in 21:70
    tracer_name = tracer_id_to_name(tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    # no mixotrophic dinoflagellates 
    if 44 <= tracer_id <= 51
        val = 0
    end 
    init_list = repeat([val], nX)
    dim = "x"
    init_tracer_grid(config_obj, tracer_name, init_list, dim, (nX,nY))
end

# start with the same nutrients in each cell 
for tracer_id in 1:20
    # skip no3 and po4 (2 and 5) - set later 
    if tracer_id == 2 || tracer_id == 5
        continue
    end
    tracer_name = tracer_id_to_name(tracer_id)
    val = seed_ds[tracer_name][x, y, z, t]
    # set NO2, NH4, and DON to 0 (tracers 3, 4, and 9)
    if tracer_id == 3 || tracer_id == 4 || tracer_id == 9
        val = 0.0
    end
    init_list = repeat([val], nX)
    dim = "x"
    # add TONS of iron
    if tracer_id == 6
        init_list = init_list .* 100
    else # also make everything else MORE  
        init_list = init_list .* 10
    end
    init_tracer_grid(config_obj, tracer_name, init_list, dim, (nX,nY))
end

# set increasing phosphate along y axis 
tracer_name = tracer_id_to_name(5)
p_init_list = LinRange(0,0.05, nX)
#p_init_list = [0, 0.01, 0.05, 0.1]
#p_init_list = [0, 0.01, 0.02, 0.03]

#p_init_list = repeat([0.5], nX) # same value in each cell
dim = "y"
init_tracer_grid(config_obj, tracer_name, p_init_list, dim, (nX,nY))
# p_init_list = [0.2, 0.6]
# init_tracer_grid(config_obj, tracer_name, p_init_list)

# set increasing nitrate availability along x axis 
tracer_name = tracer_id_to_name(2)
n_init_list = LinRange(0,0.1, nX)
#n_init_list = [0, 0.01, 0.05, 0.1]
dim = "x"
init_tracer_grid(config_obj, tracer_name, n_init_list, dim, (nX,nY))
#n_init_list = [2.0, 5.0]
# init_tracer_grid(config_obj, tracer_name, n_init_list)

# Station ALOHA(ish) light 
x = 203
y = 105
z=2 # lower value for light - farther into the water column
update_radtrans(config_obj, seed_ds_par, x, y, z, t)

# FINALLY! Run! 
dar_one_run(config_obj)
