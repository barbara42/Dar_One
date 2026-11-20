# DarOne.jl

[![Tests](https://github.com/DarOneModel/DarOne.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/DarOneModel/DarOne.jl/actions/workflows/tests.yml)

Built off of Gael Forget's MITgcmTools! (https://github.com/gaelforget/MITgcmTools.jl)

[DarOne.jl Documentation](https://daronemodel.github.io/DarOne.jl/build/getting_started/)
- [tutorials](https://daronemodel.github.io/DarOne.jl/build/beginner_tutorials/)
- [case studies](https://daronemodel.github.io/DarOne.jl/build/case_studies/)

Install the registered Julia package with:

```julia
using Pkg
Pkg.add("DarOne")
```


Documentation for the darwin3 MITgcm fortran model can be found [here](https://darwin3.readthedocs.io/en/latest/phys_pkgs/darwin_bacteria.html) 
##  Overview of program structure 


DarOne.jl is a tool for designing and running experiments simulating the marine microbiome within a single cube of water. The biogeochemical forcing is powered by the [MIT Darwin Model](https://darwinproject.mit.edu/), and DarOne.jl provides a Julia interface to build, configure, and run experiments with a simple, streamlined workflow. DarOne.jl is composed of two main parts:

- [DarOne.jl](https://github.com/DarOneModel/DarOne.jl) - Julia interface for organizing experiments and setting up parameters for model runs
    - `MITgcm_path` variable should point to darwin3
- [darwin3](https://github.com/darwinproject/darwin3) - MITgcm source code set up to include all things Darwin 
    - `DarOne_config` - folder for the base configuration files for DarOne, which lives in the darwin3/verification/ folder. ([DarOne_config github](https://github.com/barbara42/dar_one_config))


DarOne can be run in one of two ways. 
1) In a **docker container** using the DarOne_docker image, where all dependencies are handled for you 
2) On your local machine, where you have to set up the environment, download dependencies, etc 
    - this is more time consuming, and I strongly recommend using the docker image
    - instructions for local setup are below

# Setting up with docker

(1) Download and install [docker desktop](https://www.docker.com/).
- Run the docker application, which will start up the docker "daemon" 
- The docker daemon must be running in order to download the DarOne image

(2) Get the [DarOne docker image](https://hub.docker.com/repository/docker/birdy1123/dar1).
- using the command line, run 

    `docker pull birdy1123/dar1`

- If you go to the "Images" tab in the docker desktop UI, you should see "birdy1123/dar1"

(3) Run a container based on the DarOne docker image
- using the command line, run 

    `docker run -it birdy1123/dar1` 
- this runs the container in interactive mode (`-i`) with terminal access (`-t`) 
- you should see the prompt change to `root@some-number:/DarOne_docker#`
    - if the container is already running, you can connect to it with `docker exec -it [CONTAINER_ID] bash`
    - Note: connecting with `bash` rather than `sh` gives you more a powerful terminal (i.e. with tab completion) 
  
You're now ready for the [beginner tutorial](beginner_tutorial)!
# Setting up on local machine

See instructions in the documentation: https://daronemodel.github.io/DarOne.jl/build/getting_started/#Setting-up-on-local-machine

## Example integration tests

The example test runner executes all nine beginner tutorial and case-study scripts, including Fortran builds, simulations, and the tutorial plot. It uses Darwin reference inputs and short simulation durations. Run it with a Darwin checkout containing `verification/dar_one_config` and a working GNU Fortran toolchain:

```bash
DARONE_MITGCM_PATH=/path/to/darwin3 julia --project=. test/test_examples.jl
```

# Contributing 

We have three main branches: `main`, `test`, and `dev`.

All other branches are feature branches. Once a feature has been implemented, tested, and documented you can make a pull request to merge it into the `dev` branch. 

`main` is the most stable version of the code. This branch is used for the docker image. 