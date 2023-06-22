
# Basic DAR1 Run

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

# Grid 

MITgcm DARWIN is built to run in a grid, calculating the fluxes as things flow from one grid cell to another. By turning off advection and diffusion between grid cells, we can essentially run DAR1 in parallel. That is, multiple blocks of water that do not interact with each other. 

In order to run DAR1 in parallel, you first must specify the number of cells in the X and Y direction before building. In this example, we're creating a 4x4 grid.

```
nX = 4
nY = 4
update_grid_size(nX, nY)
build(base_configuration)
```

!!! note 
    If you change grid size, you MUST rebuild 

If you do not want to change the size of the grid, you do not have to rebuild for each run. 

As with the basic tutorial, we then create our config object 
```
# create and set up config 
config_name = "grid-tutorial-4x4"
config_obj, rundir = create_MITgcm_config(config_name)
setup(config_obj)
```
But we now have the additional step of telling the run-time parameters that we are using a new grid size. 

```
update_delX_delY_for_grid(config_obj, nX, nY) 
```

Setting up how long to run for and the write frequency is the same as a basic run. However, setting the tracer values for each grid cell is slightly different. In the basic example, we are running a 1x1 grid, so we only have 1 set of initial values to specify. In a larger grid, we must specify the tracer values for each grid cell. This is done by creating an nX by nY matrix for each tracer then using the `init_tracer_grid` method. 

```
tracer_name = "TRAC21" #prochloroccocus
# create a 4x4 matrix where each value is 0.01
init_matrix = repeat(repeat([0.01], 4), outer=(1,4)) 
init_tracer_grid(config_obj, tracer_name, init_matrix)
```

To set all nutients, it is easiest to do it in a for loop. Here I am using values grabbed from surface waters slightly north of Hawaii in August. At first, I am setting nutrient values to be the same across all grid cells. 

```
nutrients = [1920.6353
4.3627567
0.114378
0.23194869
0.6204238
3.8048208e-7
2.5234492
0.8200485
0.1093398
0.0068337377
6.8771224e-6
0.0664213
0.008856173
0.0005535108
5.535108e-7
0.0017452012
0.0008702652
2286.9731
208.42433]

for i in range(1, 19)
    init_matrix = repeat(repeat([nutrients[i]], 4), inner=(1,4))
    tracer_name = tracer_id_to_name(i) # tracer ID conveniently lines up with indexing nutrients
    init_tracer_grid(config_obj, tracer_name, init_matrix)
end
```
Now, I want to change the NO3 levels to be increasing along one axis. 

```
tracer_name = "TRAC02"
no3_matrix = repeat(transpose(LinRange(3.0, 8.0, 4)), outer=(4,1))
init_tracer_grid(config_obj, tracer_name, init_matrix)
```

Reminder, to find a list of all the tracers and their respectice IDs and names, see [darwin background](LINK TODO).

Lastly, temperature is treated differently from tracers, so it has it's own initialization function `init_temperature_grid`. Here we will set the grid to have increasing temperature along the one axis. 

```
temp_matrix = repeat(LinRange(20, 40, 4), inner=(1,4))
init_temperature_grid(config_obj, init_matrix)
```

And finally, we can run! 
```
dar_one_run(config_obj)
```

To recap, in this example we created a 4x4 grid of DAR1s, each with the same initial amount of nutrients (with the exception of NO3) and prochlorococcus. Along one axis, we initialized each grid cell to have 3.0, 4.67, 6.33, and 8.0 mmol NO3, and along the other axis we set the temperature to be 20.0, 26.67, 33.33, and 40.0 degrees C. 


# Constant Nutrients 

In a normal DAR1 configuration, the nutrients cycle through organic pathways and are then remineralized. When organisms grow, they take the nutrients out of the water and turn them into biomass. In a "constant nutrient" state, however, we can hold the amount of nutrients available in the water constant, so that the uptake by organisms doesn't deplete the reserve. 

With DAR1 you can hold any subset of the nutrients constant. As with a grid setup, this requires built-time changes, made by using the `hold_nutrients_constant` method before building. There are 19 nutrient tracers (DIC, NO3, NO2, NH4, PO4, SiO2, FeT, DOC, DON, DOP, DOFe, PIC, POC, PON, PIP, PISi, POFe, ALK, O2), and `hold_nutrients_constant` takes a list of length 19, each element representing the nutrients in the order they are listed. In that list, a 0 represents holding a nutrient constant (dN/dt = 0), and 1 means that the concentration of that nutrient will be depleted and replentished with biomass growth and remineralization. 

To set all nutrients constant, use the following code 

```
param_list = zeros(19) # hold everything constant 
hold_nutrients_constant(param_list)
# BUILD 
build(base_configuration)
```

Here is an example of allowing most nutrients to cycle, but hold only iron (FeT) constant. 

```
param_list = zeros(19) # hold everything constant 
param_list[7] = 1 # FeT is 7th in the list of nutrients (TRAC07)
hold_nutrients_constant(param_list)
# BUILD 
build(base_configuration)
```

!!! note 
    If you change nutrient cycling, you MUST rebuild 

After doing this once, in the future you should always specify which nutrients you hold constant or allow to cycle in future builds. To make sure all nutrients are allowed to cycle, use the following code 

```
param_list = ones(19) # let all nutrients cycle 
hold_nutrients_constant(param_list)
# BUILD 
build(base_configuration)
```

