# Dar_One Documentation  

**Organzied descriptions of how to modify certain parameters for Dar_One**

Darwin has many ways to control and tweak a simulation. You can change things such as how hot or cold
it is, the intensity of the sunlight, how much of a nutrient is available, etc. Below you will find an explanation of the most commonly used parameters to design your own unique experiments! 

In order to modify the run-time parameters for `dar_one`, you first need to create and save a unique [`MITgcm_config`](@ref) object, along with running the `setup` method. This sets up a folder with sub-folders where all the input files live and where the output will be saved. The `MITgcm_config` object holds a reference to these folders, so you don't have to remember the whole filepath. 
To create and setup the `MITgcm_config` object, use the following code:
```
# create config object 
project_name = "dar_one_example"
config_obj, rundir = create_MITgcm_config(project_name)
setup(config_obj)
```
See [`create_MITgcm_config`](@ref) and [setup](@ref).

!!! note
    You can only run the `setup` function once per unique project name! If you try to run it again with a non-unique project name it will throw an error. Once the filesystem is set up, you can comment out that
    line while troubleshooting your simulation. 

## Timing 

As with any biogeochemical simulation, you have to choose how long you want the model to run. With
`Dar_One`, frequently the goal is to run the model until it reaches a steady-state or oscillatory steady-state. This can take any number of years depending on how close your initial conditions are to
the steady-state. 

`Dar_One` thinks about time either in "iterations" or seconds. It is configured to run in 3-hour time steps,
and each of those steps is an iteration. The default is for it to run for a year (360 days, 2880 iterations).
To change this value, use the [`update_end_time`](@ref) function.
```
end_time = 2880 # one year, in iterations
update_end_time(end_time, config_obj)
```

In addition to how long the model runs, you can change how frequently the state of the model
is written to a file, called a "diagnostic". The more frequently you write to the diagnostics, 
the longer the run will take. 

To update the diagnostic write frequency, use the method [`update_diagnostic_freq`](@ref). The value 
it takes is in seconds, so to get output every month you would use 2592000. Every year would be 31104000. 

For now, `diagnostic_num` refers to which diagnostic you're changing. `Dar_One` output many diagnostic files 
that contain various info, but the most commonly used one is the `3d` file. This file contains all the tracer information, such as nutrient concentrations and plankton biomass. For `3d` the `diagnostic_num` is 1.

```
month = 2592000
update_diagnostic_freq(config_obj, 1, month)
```
The default frequency is to write to all diagnostics once a month. 

## Temperature 

Updating the temperature of the model is easy! Simply use the [`update_temperature`](@ref) function. 

```
update_temperature(config_obj, 25.5)
```

## Nutrients 

how to update nutrient params 

## Biology 

live things! 

# Advanced Stuff 

## Sunlight
gonna have to make files and change params 

## Predetor/Prey Interactions 

ummm idk yet 

## Update Generic Parameter  

```@docs
update_param
```

## Output Description 

Explanation of all the different output files 

2d.0000000000.t001.nc			chl.0000002880.t001.nc
2d.0000002880.t001.nc			grid.t001.nc
3d.0000000000.t001.nc			nutr_tend.0000000000.t001.nc
GR.0000000000.t001.nc			nutr_tend.0000002880.t001.nc
GR.0000002880.t001.nc			par.0000000000.t001.nc
GRGN.0000000000.t001.nc			par.0000002880.t001.nc
GRGN.0000002880.t001.nc			ptr_flux_tave.0000002880.t001.nc
PC.0000000000.t001.nc			ptr_tave.0000002880.t001.nc
PC.0000002880.t001.nc			ptracers.0000000000.t001.nc
PP.0000000000.t001.nc			ptracers.0000002880.t001.nc
PP.0000002880.t001.nc			tave.0000002880.t001.nc
chl.0000000000.t001.nc

