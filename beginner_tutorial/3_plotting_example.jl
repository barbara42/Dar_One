include("../src/DarOneTools.jl")
using .DarOneTools
using NCDatasets
using Plots

# the path to the Darwin version of the MITgcm
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)

# the unique name of your run 
project_name = "radtrans_test_10" # CHANGE ME
ecco_folder_name = "ecco_gud_20221115_0001" #CHANGE ME

# re-create the config object
config_obj, rundir = create_MITgcm_config(project_name)

# open the 3d file into a NCDataset
file_3d_name = "3d.0000000000.t001.nc"
ds = Dataset(joinpath(rundir, ecco_folder_name, file_3d_name))

# plot Prochlorococcus abundance over time 
p = plot(ds["TRAC21"][1, 1, 1, :], title="Prochlorococcus Abundance", xlabel="Time", ylabel="Pro [mmol C]", label="Pro")
display(p)

# YOUR TURN: show the plot for Synechococcus! 
# TRAC21 = pro, TRAC22 = syn 

