# Using Dar_One in a Grid 

Running multiple `Dar_One` experiments in parallel.

Setting ptracer initial values 
-  `PTRACERS_initialFile ` instead of `PTRACERS_ref`
- initial file is a `bin` file in the format...

For a 30x30 grid, each tracer will have a 30x30 bin file. 

`bin` files will be placed in the config run folder, under the folder `bin_files`, and each file should be named something accordingly, i.e. `no3_seeds.bin`


There will be a handful of default grid builds 
- 30x30 


## Creating a grid build 

Choose the size of your grid, `(X, Y)`.

Update SIZE.h file 
- set `sNx = X` and `sNy = Y`

*build* 

### Runtime parameters 

`data`
- PARM04
    - delX=X*1.E0,
    - delY=Y*1.E0,
    
```@docs
update_delX_delY_for_grid
```

```@docs
init_tracer_grid
```