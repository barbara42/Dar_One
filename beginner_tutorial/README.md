# Dar_One Beginner Tutorial

BEFORE YOU START:

Follow the setup guide for using the [dar_one_docker image](../README.md/#setting-up-with-docker) or for [local machine setup](../README.md/#setting-up-on-local-machine). (HIGHLY recommend using docker over setting up your own machine) 
## Overview 

In this tutorial, we are going to set up an experiment with a small amount of nitrate (NO3),
phosphate (PO4), and iron (FeT), along with a single organism representing Prochlorococcus. 
Then, we are going to add in another organism representing Synechococcus, and see 
how the steady-state changes. 

## Building and Dependencies 

If you're using the `dar_one_docker`...
- you don't have to do anything! 
- I already built the mitgcm executable for the docker container
    - the executable is called `mitgcmuv` and lives in the `darwin3/verification/dar_one_config/build` directory 
- all the julia depencies have also been install already! 
- navigate to the `beginner_tutorial` folder using the command line (`# cd Dar_One/beginner_tutorial`)

If you're doing it locally... 
- install julia dependencies
    - TODO: list dependencies
- run `# julia 1_build_example.jl`
- TODO: more info and troubleshooting to come

## Setting up run folders 

This is a very simple tutorial, so I'll walk you through line-by-line whats going on in the 
`2_run_example.jl` file. 

If you're using docker, to open up the file using the commandline, run 
`# vim 2_run_example.jl`. Then you can use [vim commands](https://coderwall.com/p/adv71w/basic-vim-commands-for-getting-started) to explore and edit the file. 

(1) First, we have to import our dependencies.

```
# DarOneTools
include("../src/DarOneTools.jl")
using .DarOneTools
# other packages 
using ClimateModels
```
The `include` statement loads the `DarOneTools` from the `/src` directory. Perhaps in the future 
`DarOneTools` will be a julia package that can be installed with the package manager, but for now
its simply local code that we load up! The `.` in front of `DarOneTools` tells julia to look inside
the current module for `DarOneTools`.  

(2) After including our dependencies, we have to specify the `MITgcm_path`. This tells `Dar_One` where 
to look for the Darwin MITgcm code. The default value will work if using the docker. Otherwise, 
paste in the path to where you downloaded `darwin3`. 
```
# the path to the Darwin version of the MITgcm 
MITgcm_path[1] = "/dar_one_docker/darwin3" # CHANGE ME (unless using docker)
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

For a full list of parameters to modify, including more in-depth descriptions, see DOCUMENTAION(TODO - link).

Whenever you update a parameter, the function first takes in the `config_obj` of type `MITgcm_config` that we created in the previous step. This tells `Dar_One` where the files are that we are 
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
`Dar_One` by default doesn't have many nutrients available, only salinity, alkalinity, and oxygen 
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

If you're using docker, you can run this file by using the command (in the docker bash prompt)
`# julia 2_run_example.jl` 

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
[ Info: 1 Output in directory /dar_one_docker/darwin3/verification/dar_one_config/run/beginner_tutorial/run, most recent ecco folder 
```
Don't worry, those warnings are totally normal :) 

## Understanding and Plotting Results 

As the output from the previous run suggests, all of the information about your simulation lives in the folder `/dar_one_docker/darwin3/verification/dar_one_config/run/beginner_tutorial/run` (or, if running locally, underneath your `darwin3` folder). 

Let's look at the contents of this folder
`# cd /dar_one_docker/darwin3/verification/dar_one_config/run/beginner_tutorial/run`
`# ls`

You'll see a lot of files, but look for the folder that starts with `ecco_gud_[DATE]_0001`. 

Let's move inside this folder and look at its contents. 
`# cd ecco_gud_[DATE]_0001`
`# ls` 

Here's all our output, in [netCDF](https://www.unidata.ucar.edu/software/netcdf/) form! You can tell by the `.nc` filetype extension at the end of each file name. Each of these files contains different information about whats going on inside `Dar_One`, but for now **we are just going to focus on the `3d.some_number.nc` file.** (For a more in-depth description of all the forms of output we get, see [DOCUMENTATION](TODO: LINK))

The `3d.nc` file contains information about nutrient levels and the biomass of all the phytoplankton types. 






