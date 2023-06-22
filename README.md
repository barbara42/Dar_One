# DAR1

Built off of Gael Forget's MITgcmTools! (https://github.com/gaelforget/MITgcmTools.jl)

[DAR1 Documentation](https://barbara42.github.io/Dar_One/build/)
- [tutorials](https://barbara42.github.io/Dar_One/build/beginner_tutorials/)
- [case studies](https://barbara42.github.io/Dar_One/build/case_studies/)

##  Overview of program structure 


DAR1 is a tool for designing and running experiments simulating the marine microbiome within a single cube of water. The biogeochemical forcing is powered by the [MIT Darwin Model](https://darwinproject.mit.edu/), and DAR1 provides a Julia interface to build, configure, and run experiments with a simple, streamlined workflow. DAR1 is composed of two main parts:

- [DAR1](https://github.com/barbara42/Dar_One) - Julia interface for organizing experiments and setting up parameters for model runs 
    - `MITgcm_path` variable should point to darwin3
- [darwin3](https://github.com/darwinproject/darwin3) - MITgcm source code set up to include all things Darwin 
    - `DAR1_config` - folder for the base configuration files for DAR1, which lives in the darwin3/verification/ folder. ([DAR1_config github](https://github.com/barbara42/dar_one_config))


DAR1 can be run in one of two ways. 
1) In a **docker container** using the DAR1_docker image, where all dependencies are handled for you 
2) On your local machine, where you have to set up the environment, download dependencies, etc 
    - this is more time consuming, and I strongly recommend using the docker image
    - instructions for local setup are below

# Setting up with docker

(1) Download and install [docker desktop](https://www.docker.com/).
- Run the docker application, which will start up the docker "daemon" 
- The docker daemon must be running in order to download the DAR1 image

(2) Get the [DAR1_docker image](https://hub.docker.com/repository/docker/birdy1123/dar1).
- using the command line, run 

    `docker pull birdy1123/DAR1_docker`

- If you go to the "Images" tab in the docker desktop UI, you should see "birdy1123/DAR1_docker"

(3) Run a container based on the DAR1_docker image
- using the command line, run 

    `docker run -it birdy1123/DAR1_docker` 
- this runs the container in interactive mode (`-i`) with terminal access (`-t`) 
- you should see the prompt change to `root@some-number:/DAR1_docker#`

You're now ready for the [beginner tutorial](beginner_tutorial)!
# Setting up on local machine

If you have a windows machine, abandon all hope or dual boot linux 

TODO

# Contributing 

We have three main branches: `main`, `test`, and `dev`.

All other branches are feature branches. Once a feature has been implemented, tested, and documented you can make a pull request to merge it into the `dev` branch. 

`main` is the most stable version of the code. This branch is used for the docker image. 