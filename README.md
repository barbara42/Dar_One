# Dar_One
a zero-D environment in julia powered by Darwin and MITgcm

Built off of Gael Forget's MITgcmTools! (https://github.com/gaelforget/MITgcmTools.jl)

# Setup

Dar_One can be run in one of two ways. 
1) In a **docker container** using the dar_one_docker image, where all dependencies are handled for you 
2) On your local machine, where you have to set up the environment, download dependencies, etc 
    - this is more time consuming, and I strongly recommend using the docker image
    - instructions for local setup are below

##  Overview of program structure 

Dar_One is a Julia interface for using the [MITgcm](https://mitgcm.org/) with a [Darwin](https://darwinproject.mit.edu/) configuration to include biogeochemical forcing for marine microbes. This means it's composed of two main parts
- [Dar_One Julia](https://github.com/barbara42/Dar_One) - interface for organizing experiments and setting up parameters for model runs 
    - `MITgcm_path` variable should point to darwin3
- [darwin3](https://github.com/darwinproject/darwin3) - MITgcm source code set up to include all things Darwin 
    - `dar_one_config` - folder for the base configuration files for Dar_One, which lives in the darwin3/verification/ folder. ([dar_one_config github](https://github.com/barbara42/dar_one_config))

# Setting up with docker

(1) Download and install [docker desktop](https://www.docker.com/).

(2) Get the [dar_one_docker image](https://hub.docker.com/repository/docker/birdy1123/dar_one_docker).
- using the command line, run 

    `docker pull birdy1123/dar_one_docker`

- If you go to the "Images" tab in the docker desktop UI, you should see "birdy1123/dar_one_docker"

(3) Run a container based on the dar_one_docker image
- using the command line, run 

    `docker run -it birdy1123/dar_one_docker` 
- this runs the container in interactive mode (`-i`) with terminal access (`-t`) 
- you should see the prompt change to `root@some-number:/dar_one_docker#`

You're now ready for the [beginner tutorial](beginner_tutorial/README.md)!
# Setting up on local machine

If you have a windows machine, abandon all hope or dual boot linux 

TODO! 

# Contributing 

We have three main branches
- main
- test
- dev 

All other branches are feature branches. Once a feature has been implemented, tested, and documented you can make a pull request to merge it into the `dev` branch. From there, it will be deployed (hopefully in the future). If the deploy passes, it will automatically get merged into the `test` branch. 

This branch is for people who deeply understand the code and want to beta test new features. Once apropriate testing and tutorials have been created, there will be a merge planned for `main`. 

`main` is the most recent and stable version of the code. This branch is used for the docker image. 