
# Basic 

# Grid 

MITgcm DARWIN is built to run in a grid, calculating the fluxes as things flow from one grid cell to another. By turning off advection and diffusion between grid cells, we can essentially run DAR1 in parallel. That is, multiple blocks of water that do not interact with each other. 

In order to run DAR1 in parallel, you first must specify the number of cells in the X and Y direction before building. In this example, we're creating a 4x4 grid.

```
nX = 4
nY = 4
update_grid_size(nX, nY)
build(base_configuration)
```

!!!note 
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

After doing this once, in the future you should always specify which nutrients you hold constant or allow to cycle in future builds. To make sure all nutrients are allowed to cycle, use the following code 

```
param_list = ones(19) # let all nutrients cycle 
hold_nutrients_constant(param_list)
# BUILD 
build(base_configuration)
```

