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
    - Darwin3 sources are located automatically (see local setup below).
- [darwin3](https://github.com/darwinproject/darwin3) - MITgcm source code set up to include all things Darwin 
    - [`dar_one_config`](https://github.com/barbara42/dar_one_config) - base configuration, managed independently of the Darwin3 source tree.


DarOne can be run in one of two ways. 
1) In a **docker container** using the DarOne_docker image, where all dependencies are handled for you 
2) On your local machine, where you have to set up the environment, download dependencies, etc 
    - this is more time consuming, and I strongly recommend using the docker image
    - instructions for local setup are below

# Setting up with docker

(1) Download and install [docker desktop](https://www.docker.com/).
- Run the docker application, which will start up the docker "daemon" 
- The docker daemon must be running in order to download the DarOne image

(2) Get the [DarOne docker image](https://hub.docker.com/r/birdy1123/dar1).
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

## Darwin3 sources

DarOne automatically downloads the pinned Darwin3 and `dar_one_config`
revisions in [`darwin-sources.env`](darwin-sources.env) on first use. Sources
are cached separately from writable build and experiment directories. Building
requires Git, GNU Fortran, `make`, NetCDF and Python.

```julia
using DarOne
build(base_configuration)
```

To use existing local checkouts, set `DARONE_MITGCM_PATH` and optionally
`DARONE_CONFIG_PATH` for a configuration outside the Darwin3 tree:

```bash
export DARONE_MITGCM_PATH="$HOME/src/darwin3"
export DARONE_CONFIG_PATH="$HOME/src/dar_one_config"
```

To use different managed source revisions, specify their full Git commit hashes:

```bash
export DARONE_DARWIN_REV="<40-character-Darwin3-commit>"
export DARONE_CONFIG_REV="<40-character-dar_one_config-commit>"
```

Existing scripts that assign `MITgcm_path[1]` remain supported.

## Example integration tests

The example test runner executes all nine beginner tutorial and case-study scripts, including Fortran builds, simulations, and the tutorial plot. It uses Darwin reference inputs and short simulation durations. With Git and
the GNU Fortran/NetCDF toolchain installed, the test runner automatically
provisions the pinned source/configuration pair:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

# Contributing 

We have three main branches: `main`, `test`, and `dev`.

All other branches are feature branches. Once a feature has been implemented, tested, and documented you can make a pull request to merge it into the `dev` branch. 

`main` is the most stable version of the code. This branch is used for the docker image. 