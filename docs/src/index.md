# Modifying Parameters 

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
<<<<<<< HEAD
See [`create_MITgcm_config`](@ref).
=======
See [`create_MITgcm_config`](@ref). 
>>>>>>> 3af4ec3 (added links where TODOs were marked in the docs)

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

For now, `diagnostic_num` refers to which diagnostic you're changing. `Dar_One` outputs many diagnostic files 
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
## Updating Tracers 

The term "tracer" refers to anything that's in the water that isn't H2O itself. This includes nutients and biomass. There are a number of named functions for nutrients and biomass, which are listed below! 

<<<<<<< HEAD
If the tracer you want to update doesn't have its own function, you can update any tracer you know the "id" of using the following function. Tracer IDs can be found under Darwin Background > [Tracers](https://barbara42.github.io/Dar_One/build/darwin_background/#Nutrients-TRAC01-TRAC20)
=======
If the tracer you want to update doesn't have its own function, you can update any tracer you know the "id" of using the following function. Tracer IDs can be found under Darwin Background > [Tracers](https://barbara42.github.io/Dar_One/build/darwin_background/#Tracers)
>>>>>>> 3af4ec3 (added links where TODOs were marked in the docs)

```@docs
update_tracer
```

Nutrients 
- [update_NO3](@ref)
- [update_NO2](@ref)
- [update_NH4](@ref)
- [update_PO4](@ref)
- [update_FeT](@ref)
- [update_SiO2](@ref)
- [update_DOC](@ref)
- [update_DON](@ref)
- [update_DOP](@ref)
- [update_DOFe](@ref)
- [update_POC](@ref)
- [update_PON](@ref)
- [update_POP](@ref)
- [update_POFe](@ref)
- [update_POSi](@ref)
- [update_PIC](@ref)
- [update_ALK](@ref)
- [update_O2](@ref)
- [update_CDOM](@ref)


Biology 
- [update_pro](@ref)
- [update_syn](@ref)

## Updating Tracers in Bulk

Using a "Seed" netCDF File 

<<<<<<< HEAD
Often, I use the output of a global Darwin run to initialize (or seed) the values of DAR1. The tracer values from Darwin are output in a file called `3d.nc`. When working with netCDF files, I use the package NCDatasets. 
=======
Often, I use the output of a global Darwin run to initialize (or seed) the values of DAR1. The tracer values from Darwin are output in a file called `3d.nc`. When working with netCDF files in Julia, I use the package NCDatasets. 
>>>>>>> 3af4ec3 (added links where TODOs were marked in the docs)

First, we need to include NCDatasets, then load up the contents of the file into a Dataset.
```
using NCDatasets

seed_file_3d = "path/to/file/3d.nc"
seed_ds_3d = Dataset(seed_file_3d)
```
To be finished soon... 

## Update Generic Parameter  

```@docs
update_param
```

