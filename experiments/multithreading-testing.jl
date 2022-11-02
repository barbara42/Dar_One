include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets

println("Julia running with $(Threads.nthreads()) threads")
MITgcm_path[1] = "/Users/birdy/Documents/eaps_research/darwin3/"

# load a seed file
seed_file = "/Users/birdy/Documents/eaps_research/gcm_analysis/gcm_data/jan_7_2022/3d.0000000000.nc"
seed_ds = Dataset(seed_file)
x = 203
y = 105
z= 1
t = 40 # AUG

num_simulations = 4
config_objs = Vector{MITgcm_config}()
# Set up the configs for each run 
for num in 1:num_simulations
    # set up the config 
    project_name = "sim-$num"
    config_obj, rundir = create_MITgcm_config(project_name)
    setup(config_obj)
    println("done with setting up configuration $project_name")
    
    # diagnostic frequency
    frequency = 2592000*3 # every 3 months
    update_diagnostic_freq(config_obj, 1, frequency)
    update_diagnostic_freq(config_obj, 2, frequency)
    update_diagnostic_freq(config_obj, 4, frequency)
    update_diagnostic_freq(config_obj, 5, frequency)
    update_diagnostic_freq(config_obj, 6, frequency)
    update_diagnostic_freq(config_obj, 7, frequency)
    update_diagnostic_freq(config_obj, 8, frequency)
    update_diagnostic_freq(config_obj, 10, frequency)
    update_diagnostic_freq(config_obj, 11, frequency)

    # how long to run for 
    update_end_time(config_obj, 2880)  # end after 1 years
    
    # set temperature
    update_temperature(config_obj, 10)

    # update parameters 
    # nutrients to keep constant: 1 (DIC), 18 (ALK), 19 (O2)
    const_nuts = [1, 18, 19]
    update_tracers(config_obj, const_nuts, seed_ds, x, y, z, t, 1)

    nutrients = 2:17 # not including 1 (DIC), 18 (ALK), 19 (O2)
    pico = 21:24

    update_tracers(config_obj, nutrients, seed_ds, x, y, z, t, 1)
    update_tracers(config_obj, pico, seed_ds, x, y, z, t, 1)


    println("done with updating params for  $project_name")
    push!(config_objs, config_obj)
    
end

println("Total of $(length(config_objs)) Dar_One projects to be run")

# Start each run
Threads.@threads for config_obj in config_objs
    println("started $(config_obj.ID) on thread $(Threads.threadid())")
    dar_one_run(config_obj)
    println("finished $(config_obj.ID) on thread $(Threads.threadid())")
end