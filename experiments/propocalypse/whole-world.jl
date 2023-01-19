include("../../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets



# update SIZE.h 
# BUILD 

# load seed files - these are from global darwin runs 
seed_file_3d = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/3d.nc"
seed_file_temp = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/tave.nc"
seed_file_par = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/darwin_weekly_seasonal/par.nc"
seed_ds_3d = Dataset(seed_file_3d)
seed_ds_temp = Dataset(seed_file_temp)
seed_ds_par = Dataset(seed_file_par)

# set up size of your grid 

nX = 90
nY = 40

# what slice do we want?
# these are INDICES so must be INTEGERS
z = 1
# x = collect(1:90)
# y= collect(1:40)

x = collect(91:180)
y= collect(1:40)

# x = collect(181:270)
# y= collect(1:40)

# x = collect(271:360)
# y= collect(1:40)

x_idxs = [(1,90), (91,180), (181, 270), (271,360)]
y_idxs = [(1,40), (41,80), (81, 120), (121, 160)]
t = 1
for t in 1:4:52
    for x_idx in 1:4
        for y_idx in 1:4
            # if x_idx ==1 && y_idx==1
            #     continue
            # end
            # what slice do we want?
            # these are INDICES so must be INTEGERS
            x = collect(x_idxs[x_idx][1]:x_idxs[x_idx][2])
            y= collect(y_idxs[y_idx][1]:y_idxs[y_idx][2])
            z=1
            t=1
            config_name = "globe-MONTH-$t-$x_idx-$y_idx"
            config_obj, rundir = create_MITgcm_config(config_name)
            setup(config_obj)

            # length of run 
            end_time = 2880*10 # 2880 is one year, in iterations
            update_end_time(config_obj, end_time)

            # output frequency 
            frequency = 2592000*12*2 # 2592000 is one month, in seconds 
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
            # temp_matrix = zeros(Float32, nY, nX)
            # temperature = 10
            # fill!(temp_matrix, temperature)
            temp_matrix = seed_ds_temp["Ttave"][x, y, z, t]
            init_temperature_grid(config_obj, temp_matrix)

            # create bin files for light 
            z=3 # lower value for light - farther into the water column
            init_radtrans_grid_xy(config_obj, seed_ds_par, x, y, z, t)

            # FINALLY! Run! 
            dar_one_run(config_obj)
        end
    end
end 

