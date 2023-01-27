using NCDatasets
using Glob

lats = range(105, 130, step=2)
times = range(1, 52, step=4)

# create new nc files with all the data from one run in a single file
folder = "/Users/birdy/Documents/eaps_research/darwin3/verification/dar_one_config/run"
for lat in lats
    for t in times
        # set up the config 
        config_id = "RADTRANS-propocalypse-$lat-$t"
        println(config_id)
        data_folder = "ecco_gud_20221115_0001" # CHANGE ME
        rundir = joinpath(folder, config_id, "run")
        glob_dir = joinpath(rundir, data_folder)
        alldata = glob("3d*.nc", glob_dir) # all 20 years 
        try 
            ds = Dataset(alldata)
            write("3d.$config_id.nc", ds)
            println("done with $config_id")
        catch e
            println("Wrong date in the ecoo folder causing error")
            println(e)
            continue
        end
    end
end