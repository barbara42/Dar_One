# DarOne.jl Beginner Tutorial

Start with the [getting-started guide](https://daronemodel.github.io/DarOne.jl/build/getting_started/) to install DarOne and prepare Darwin3.
## Overview 

In this tutorial, we are going to set up an experiment with a small amount of nitrate (NO3),
phosphate (PO4), and iron (FeT), along with a single organism representing Prochlorococcus. 
Then, we are going to add in another organism representing Synechococcus, and see 
how the steady-state changes. 

## Building and Dependencies 

From your local DarOne.jl checkout, install the Julia dependencies and run the example scripts:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
export DARONE_MITGCM_PATH="/absolute/path/to/darwin3"
julia --project=. beginner_tutorial/1_build_example.jl
julia --project=. beginner_tutorial/2_run_example.jl
```

The Darwin3 checkout and Fortran toolchain are described in the getting-started guide.

## Setting up run folders 

This is a very simple tutorial, so I'll walk you through line-by-line whats going on in the 
`2_run_example.jl` file. 

To open the file from the `beginner_tutorial` directory, run `vim 2_run_example.jl`. Then you can use [vim commands](https://coderwall.com/p/adv71w/basic-vim-commands-for-getting-started) to explore and edit the file. 

(1) First, we have to import our dependencies.

```
# DarOne
using DarOne
# other packages 
using ClimateModels
```
The `using` statement loads `DarOne` from the project environment (selected with `--project=..` when running from `beginner_tutorial`).

(2) After including our dependencies, we have to specify the `MITgcm_path`. This tells `DarOne.jl` where 
to look for the Darwin MITgcm code. Set the path to your Darwin3 checkout when using an installation that requires an explicit path. 
```
# the path to the Darwin version of the MITgcm 
MITgcm_path[1] = "/absolute/path/to/darwin3"
```
Next, we create a unique identifier for our run. 
```
# unique name for your run 
config_id = "beginner_tutorial" # CHANGE ME
```
Then, we create an `MITgcm_config` object using that identifier 
```
# create config object 
config_obj, rundir = create_MITgcm_config(config_id)
```
Lastly, we have to run `setup` to create the directories and files that your simulation is 
going to use. 
```
# Set up! Creating file structure and linking stuff
setup(config_obj)
```
**The `setup` fuction can only be run once per unique identifier. While you are troubleshooting
the parameteres, comment this line out!**

Awesome! Now we have a `config_obj` that points to all the files and folders needed for the run.

## Modifying Parameters 

For a full list of parameters, see the [parameter reference](https://daronemodel.github.io/DarOne.jl/build/).

Whenever you update a parameter, the function first takes in the `config_obj` of type `MITgcm_config` that we created in the previous step. This tells `DarOne.jl` where the files are that we are 
aiming to modify. 

For this tutorial, we are keeping it simple. First, we are going to specify how long the model will run by setting the end time. 
```
# length of run 
end_time = 2880 # one year, in iterations
update_end_time(end_time, config_obj)
```
Next we will set the temperature to a constant value. 
```
# temperature
new_temp = 30 # celius
update_temperature(config_obj, new_temp)
```
`DarOne.jl` by default doesn't have many nutrients available, only salinity, alkalinity, and oxygen 
are initialized. We need to add in starting nutrient concentrations, so our little plankton 
don't die off. We're going to set the initial concentrations of nitrate (NO3), phosphate (PO4), and iron (FeT) using the following code. These values are in mmol per m^3. These values were chosen 
by looking at the range of nutrient concentrations we see in the Northern Pacific gyre.  

```
# NO3
new_NO3_val = 2 
update_NO3(config_obj, new_NO3_val)
#PO4
new_PO4_val = 0.1
update_PO4(config_obj, new_PO4_val)
# FeT
new_FeT_val = 1e-3
update_FeT(config_obj, new_FeT_val)
```
Finally, we will set the initial concentration of Procholorococcus. 
```
# Prochlorococcus (mmol per m^3)
pro_val = 1e-3
update_pro(config_obj, pro_val)
```

Now that we have all of our desired parameters set, we are ready to run the model. 
```
dar_one_run(config_obj)
```

You can run this file from the `beginner_tutorial` directory with
`julia --project=.. 2_run_example.jl` 

You should see output similar to this:

```
[ Info: 1 launching...
[ Info: 1 using MITgcm_launch in ModelSteps.jl
[ Info: 1 launching in ModelSteps!
** WARNING ** DARWIN_EXF_READPARMS: default constant wind speed   5.000 m/s is used
** WARNING ** OFFLINE_RESET_PARMS: => turn on exactConserv to compute wVel
SET_REF_STATE: Unable to compute reference stratification
SET_REF_STATE:  with EOS="POLY3" ; set dBdrRef(1:Nr) to zeros
Note: The following floating-point exceptions are signalling: IEEE_UNDERFLOW_FLAG
STOP NORMAL END
[ Info: 1 run did not fail!!!!! 
[ Info: 1 run completed
[ Info: 1 time elapsed: 50.518673042 seconds
[ Info: 1 Output in directory .../darwin3/verification/dar_one_config/run/beginner_tutorial/run, most recent ecco folder 
```
These warnings can occur during a successful run; check for `STOP NORMAL END` and the expected diagnostics.

## Understanding and Plotting Results 

The simulation output is saved under `darwin3/verification/dar_one_config/run/<experiment-name>/run` in your source checkout. 

Let's look at the contents of this folder
`cd /absolute/path/to/darwin3/verification/dar_one_config/run/<experiment-name>/run`
`# ls`

You'll see a lot of files, but look for the folder that starts with `ecco_gud_[DATE]_0001`. 

Let's move inside this folder and look at its contents. 

`# cd ecco_gud_[DATE]_0001`

`# ls` 

Here's all our output, in [netCDF](https://www.unidata.ucar.edu/software/netcdf/) form! You can tell by the `.nc` filetype extension at the end of each file name. Each of these files contains different information about whats going on inside `DarOne.jl`, but for now **we are just going to focus on the `3d.some_number.nc` file.** (For a more in-depth description of all the forms of output we get, see [Darwin background](https://daronemodel.github.io/DarOne.jl/build/darwin_background/))

The `3d.nc` file contains information about nutrient levels and the biomass of all the phytoplankton types. 






