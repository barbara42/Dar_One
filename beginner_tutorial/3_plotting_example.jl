include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets
using Plots

# the unique name of your run 
project_name = "radtrans_test_10" # CHANGE ME
ecco_folder_name = "ecco_gud_20221115_0001" #CHANGE ME

# re-create the config object
config_obj, rundir = create_MITgcm_config(project_name)

# open the 3d file into a NCDataset
file_3d_name = "3d.0000000000.t001.nc"
ds = Dataset(joinpath(rundir, ecco_folder_name, file_3d_name))

# TODO: add title and label axes  
display(plot(ds["TRAC21"][1, 1, 1, :], title="pro"))

# display(plot(ds["TRAC22"][1, 1, 1, :]))
