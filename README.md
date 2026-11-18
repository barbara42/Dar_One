# DAR1

[![Tests](https://github.com/barbara42/Dar_One/actions/workflows/tests.yml/badge.svg)](https://github.com/barbara42/Dar_One/actions/workflows/tests.yml)

Built off of Gael Forget's MITgcmTools! (https://github.com/gaelforget/MITgcmTools.jl)

[DAR1 Documentation](https://barbara42.github.io/Dar_One/build/getting_started/)
- [tutorials](https://barbara42.github.io/Dar_One/build/beginner_tutorials/)
- [case studies](https://barbara42.github.io/Dar_One/build/case_studies/)


Documentation for the darwin3 MITgcm fortran model can be found [here](https://darwin3.readthedocs.io/en/latest/phys_pkgs/darwin_bacteria.html) 
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
    - if the container is already running, you can connect to it with `docker exec -it [CONTAINER_ID] bash`
    - Note: connecting with `bash` rather than `sh` gives you more a powerful terminal (i.e. with tab completion) 
  
You're now ready for the [beginner tutorial](beginner_tutorial)!
# Setting up on local machine

See instructions in the documentation: https://barbara42.github.io/Dar_One/build/getting_started/#Setting-up-on-local-machine

## Darwin3 and configuration paths (PR1, Cycle 2)

DarOne automatically fetches the Darwin3 and `dar_one_config` Git revisions
recorded in [`darwin-sources.env`](darwin-sources.env) on first use. Git is
required to retrieve sources; GNU Fortran, `make`, `tar`, NetCDF and Python
are needed to compile and run the existing examples. Julia's `Scratch.jl`
keeps the downloaded checkouts cached across sessions, and a separate writable
configuration workspace holds builds, source modifications and experiments.
No manual symlinks or installation paths are needed for the default workflow.

DarOne stages a fresh, writable Darwin3 source tree for each build. When a
pinned Darwin3 revision contains Cog 2.3, it applies the minimal Python 3.12+
compatibility fix **only to that build copy**. Newer Cog versions are used
unchanged. The original downloaded Git revision stays intact, and the build
source location, commit, and compatibility status are recorded in
`source-provenance.txt` within DarOne's Scratch build workspace. This allows
modern Python versions without a dedicated Python 3.11 environment.

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. -e 'using DarOne; println(darwin_root()); println(configuration_root())'
```

The existing API remains unchanged:

```julia
using DarOne
update_grid_size(1, 1)
build(base_configuration)
config, rundir = create_MITgcm_config("example")
setup(config)
```

To use local source checkouts (including the previous Docker layout), set
`DARONE_MITGCM_PATH` and optionally `DARONE_CONFIG_PATH`:

```bash
export DARONE_MITGCM_PATH="$HOME/src/darwin3"
export DARONE_CONFIG_PATH="$HOME/src/dar_one_config"
```

An existing configuration under `$DARONE_MITGCM_PATH/verification/dar_one_config`
is still recognised. Legacy scripts assigning `MITgcm_path[1]` remain supported.
`DARONE_MITGCM_PATH` takes precedence when set.

For future Darwin3 commits, specify the full 40-character Git revisions before
starting Julia. Each revision is downloaded into a separate cache directory;
previous versions remain available. Defaults remain pinned in
`darwin-sources.env`:

```bash
export DARONE_DARWIN_REV="<40-character-Darwin3-commit>"
export DARONE_CONFIG_REV="<40-character-dar_one_config-commit>"
```

`source_revisions()` reports the requested managed commits (an explicitly
selected local checkout may be at a different commit). You can change either
revision independently. Custom Git remotes are supported with
`DARONE_DARWIN_URL` and `DARONE_CONFIG_URL` for development or offline tests.
Environment overrides select local paths first; the managed source workspaces
are used when an explicit local checkout is not configured.

Lightweight tests, including offline Git-fixture tests, run without a Fortran
compiler:

```bash
julia --project=. test/test_paths.jl
julia --project=. test/test_sources.jl
julia --project=. test/test_build_sources.jl
```

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