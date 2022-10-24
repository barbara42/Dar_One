# Dar_One Beginner Tutorial

This tutorial is meant to be run in one of two ways. 
1) In a **docker container** using the dar_one_docker image, where all dependencies are handled for you 
2) On your local machine, where you have to set up the environment, download dependencies, etc 
    - this is more time consuming, and I strongly recommend using the docker image
    - instructions for local setup are below

##  Overview of program structure 

Dar_One is a Julia interface for using the [MITgcm](https://mitgcm.org/) with a [Darwin](https://darwinproject.mit.edu/) configuration to include biogeochemical forcing for marine microbes. This means it's composed of two main parts
- [Dar_One Julia](https://github.com/barbara42/Dar_One) - interface for organizing experiments and setting up parameters for model runs 
    - `MITgcm_path` variable should point to darwin3
- [darwin3](https://github.com/darwinproject/darwin3) - MITgcm source code set up to include all things Darwin 
    - `dar_one_config` - folder for the base configuration files for Dar_One, which lives in the darwin3/verification/ folder 

# Setting up with docker

(1) Download and install [docker desktop](https://www.docker.com/). If you're new to docker, here's some tutorials to learn more
- put
- links
- here

Building
- you don't have to do anything! I already built the mitgcm executable for the docker container
- the executable is called `mitgcmuv` and lives in the `darwin3/verification/dar_one_config/build` directory 

# Setting up on local machine

If you have a windows machine, abandon all hope or dual boot linux 


Building 






# OLD TUTORIAL 
The overall workflow of this tutorial is to run
- `darwin-setup.jl` (which creates the executable and sets up the proper folders on your machine)
- `darwin-run.jl` (where you modify runtime parameters, and then run the model)
- `darwin-plot.jl` (where we look at output)

**Note:** for the plots to show up, darwin-plot.jl must be run from a REPL or notebook. For example, I use VSCode and choose the "Execute active file in REPL" option in the run config. 

## darwin-setup.jl


To run on your local machine, make the following changes
- change `MITgcm_path[1]` to point to the root directory of your local version of the darwin MITgcm
- **note**: BUILD DOES NOT WORK FOR ME
- run darwin-setup
- copy down the `config_id` that is printed out in the terminal 

## darwin-run.jl

Make the following changes
- update `MITgcm_path[1]` to be the root directory of your local version of the darwin MITgcm
- update `config_id` to be the config_id that was output from running darwin-setup
- modifying runtime parameters
    - TODO

## darwin-plot.jl

Update 
- `config_id`
- `data_folder` (TODO: more info)
- `folder`

To see the plots this **MUST** be run from a REPL! 
