include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

# set path to MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# set up size of your grid
# running the 360x180 world in 16 quadrants in case something goes wrong midway
nX = 90
nY = 40

# BUILD STEP - commented out because I like to run it from a separate script
# # update SIZE.h 
# update_grid_size(nX, nY)

# # which nutrients can change?
# param_list = ones(19) # let all nutrients cycle normally
# hold_nutrients_constant(param_list)

# # BUILD 
# build(base_configuration)

# load seed files - these are from global darwin runs
# yearly average!  
seed_file_3d = "/dar_one_docker/3d.nc"
seed_file_temp = "/dar_one_docker/tave.nc"
seed_file_par = "/dar_one_docker/par.nc"
seed_ds_3d = Dataset(seed_file_3d)
seed_ds_temp = Dataset(seed_file_temp)
seed_ds_par = Dataset(seed_file_par)
t = 1 # yearly averages, only have one timepoint

# split X and Y into 4 quadrants each
x_idxs = [(1,90), (91,180), (181, 270), (271,360)]
y_idxs = [(1,40), (41,80), (81, 120), (121, 160)]

# cycle through all 16 quadrants
for x_idx in x_idxs
    for y_idx in y_idxs
        # what slice do we want?
        # these are INDICES so must be INTEGERS
        #x = collect(x_idxs[x_idx][1]:x_idxs[x_idx][2])
        #y = collect(y_idxs[y_idx][1]:y_idxs[y_idx][2])
        x = collect(x_idx[1]:x_idx[2])
        y = collect(y_idx[1]:y_idx[2])
        z = 1 # surface 

        # set up config 
        config_id = "globe-ss-$x_idx-$y_idx"
        config_obj, rundir = create_MITgcm_config(config_id)
        setup(config_obj)

        # length of run 
        end_time = 2880*20 # 2880 is one year, in iterations
        update_end_time(config_obj, end_time)

        # output frequency 
        frequency = 2592000*12 # 2592000 is one month, in seconds 
        update_all_diagnostic_freqs(config_obj, frequency)

        # update data > PARM04 > delX and delX
        update_delX_delY_for_grid(config_obj, nX, nY) 

        # create initial bin files for tracers that are not zero
        non_zero_tracers = cat(1:29, 35:70, dims=1)
        for tracer_id in non_zero_tracers
            tracer_name = tracer_id_to_name(tracer_id)
            init_matrix = seed_ds_3d[tracer_name][x, y, z, t]
            init_tracer_grid(config_obj, tracer_name, init_matrix)
        end

        # create initial bin files for tracers that are zero (diazotrophs)
        for tracer_id in [30,31,32,33,34]
            tracer_name = tracer_id_to_name(tracer_id)
            init_matrix = zeros(Float32, nY, nX)
            init_tracer_grid(config_obj, tracer_name, init_matrix)
        end

        # create bin file for temperatures - all 15 degrees
        temp_matrix = seed_ds_temp["Ttave"][x, y, z, t]
        init_temperature_grid(config_obj, temp_matrix)

        # create bin files for light 
        z=3 # lower value for light - farther into the water column
        init_radtrans_grid_xy(config_obj, seed_ds_par, x, y, z, t)

        # FINALLY! Run!
        dar_one_run(config_obj)
    end
end
