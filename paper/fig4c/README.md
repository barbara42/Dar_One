# Figure 4C - Bray-Curtis dissimilarity

Reproduce Figure 4C of the DAR1 manuscript using 16 independent 90 x 40
simulations initialized with the bundled Darwin annual-mean reference fields.
Each tile runs for ten years (28,800 iterations). The analysis compares the
average of the final two annual outputs with the reference community, using
45 non-diazotroph biomass tracers (21-29 and 35-70).

The instructions below run on Linux without Docker. Run the commands from the
DarOne repository root, in the **same terminal** so that the exported paths
remain set. Julia 1.10 and Conda must be installed.

## 1. Install dependencies

On Ubuntu, install the native MITgcm build dependencies:

```bash
sudo apt-get update
sudo apt-get install -y git gfortran make libnetcdf-dev libnetcdff-dev tcsh
```

Create and activate the Python 3.11 environment used for the figure. Darwin3's
build tools also require Python 3.11 (their Cog generator uses the removed
`imp` module), so keep this environment active during the model build:

```bash
cd ~/Dar_One
conda env create -f paper/fig4c/environment.yml
conda activate darone-fig4c

julia --project=. -e 'using Pkg; Pkg.instantiate()' && \
julia --project=. -e 'using DarOne; println("DarOne loads successfully")'
```

If the Conda environment already exists, simply activate it.

## 2. Locate or install Darwin3

The global case study requires Darwin3 with `dar_one_config` under
`verification/`. **Set `DARONE_MITGCM_PATH` to the real checkout directory**;
`/path/to/darwin3` is only a placeholder, not a usable path. For a new
checkout, the commands below reproduce the source revisions used by CI,
recorded in [`darwin-sources.env`](../../darwin-sources.env):

```bash
cd ~/Dar_One
set -a
. ./darwin-sources.env
set +a
export DARONE_MITGCM_PATH="$HOME/darwin3"

git init -q "$DARONE_MITGCM_PATH"
git -C "$DARONE_MITGCM_PATH" remote add origin https://github.com/darwinproject/darwin3.git
git -C "$DARONE_MITGCM_PATH" fetch --depth 1 origin "$DARWIN_REV"
git -C "$DARONE_MITGCM_PATH" checkout --quiet --detach FETCH_HEAD

config="$DARONE_MITGCM_PATH/verification/dar_one_config"
git init -q "$config"
git -C "$config" remote add origin https://github.com/barbara42/dar_one_config.git
git -C "$config" fetch --depth 1 origin "$DARONE_CONFIG_REV"
git -C "$config" checkout --quiet --detach FETCH_HEAD
mkdir -p "$config/build" "$config/run"
```

If Darwin3 and `dar_one_config` are already installed, use their existing
checkout instead: export `DARONE_MITGCM_PATH` to its actual directory and
skip the checkout commands above. Verify that the expected configuration exists:

```bash
test -f "$DARONE_MITGCM_PATH/tools/genmake2" && \
test -f "$DARONE_MITGCM_PATH/verification/dar_one_config/code/SIZE.h" && \
echo "Darwin3 configuration found at $DARONE_MITGCM_PATH"
```

## 3. Build, run and plot

The simulations are initialized from the Darwin reference fields in
[`data/darwin`](../../data/darwin) (`surface_tracers.nc`,
`surface_temperature.nc`, and `par_upper4.nc`), which the scripts read by
default. To use other Darwin output instead, set `DARONE_DATA_DIR` to a
directory containing files with those three names.

Check that `DARONE_MITGCM_PATH` is still set in this terminal. Build the
90 x 40 executable once, then run all 16 tiles and plot the final annual-mean
Bray-Curtis field:

```bash
cd ~/Dar_One
julia --project=. case_studies/global_steadystate_build.jl && \
DARONE_EXAMPLE_ITERATIONS=28800 JULIA_NUM_THREADS=4 \
  bash paper/fig4c/run_bray_curtis_tiles.sh "$HOME/darone-fig4c" && \
python paper/fig4c/plot_bray_curtis.py "$HOME/darone-fig4c"
```

The `&&` operators stop the sequence if the build or any tile simulation fails,
so plotting only starts once the simulations succeed. The launcher runs up to
`JULIA_NUM_THREADS` independent, single-threaded processes; alternatively,
set `DARONE_GLOBAL_WORKERS` to choose the worker count.

## Outputs

The figure and calculated field are saved as `~/darone-fig4c/Fig_Bray_Curtis.png`
and `~/darone-fig4c/Fig_Bray_Curtis.nc`. Per-tile logs are written to
`~/darone-fig4c/logs/`. The 16 simulation directories remain in
`$DARONE_MITGCM_PATH/verification/dar_one_config/run/`.

This ten-year manuscript reproduction is separate from routine GitHub Actions
integration tests, which run shorter simulations.
