using DarOne
using NCDatasets
using Plots

# the path to the Darwin version of the MITgcm
MITgcm_path[1] = get(ENV, "DARONE_MITGCM_PATH", "/dar_one_docker/darwin3")

# the unique name of your run 
project_name = "beginner_tutorial-pro-syn-2"

# re-create the config object
config_obj, rundir = create_MITgcm_config(project_name)

# open the 3d file from the preceding run into a NCDataset
output_folders = sort(filter(f -> startswith(f, "ecco_gud_") && isdir(joinpath(rundir, f)), readdir(rundir)))
output_dir = joinpath(rundir, last(output_folders))
files_3d = sort(filter(f -> startswith(f, "3d.") && endswith(f, ".nc"), readdir(output_dir)))
ds = Dataset(joinpath(output_dir, last(files_3d)))

# plot Prochlorococcus abundance over time 
p = plot(ds["TRAC21"][1, 1, 1, :], title="Prochlorococcus Abundance", xlabel="Time", ylabel="Pro [mmol C]", label="Pro")
if haskey(ENV, "DARONE_PLOT_FILE")
    savefig(p, ENV["DARONE_PLOT_FILE"])
else
    display(p)
end
close(ds)

# YOUR TURN: show the plot for Synechococcus! 
# TRAC21 = pro, TRAC22 = syn 

