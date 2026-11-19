# DarOne.jl

[![Tests](https://github.com/DarOneModel/DarOne.jl/actions/workflows/tests.yml/badge.svg)](https://github.com/DarOneModel/DarOne.jl/actions/workflows/tests.yml)

**DarOne.jl** provides a Julia interface for building, configuring, and running experiments with the [MITgcm DARWIN ecosystem model](https://darwinproject.mit.edu/), from a single well-mixed water parcel to grids of independent columns.

[Getting started](https://daronemodel.github.io/DarOne.jl/build/getting_started/) · [Beginner tutorials](https://daronemodel.github.io/DarOne.jl/build/beginner_tutorials/) · [Case studies](https://daronemodel.github.io/DarOne.jl/build/case_studies/)

## Installation

Install the Julia package from the General registry:

```julia
import Pkg
Pkg.add("DarOne")
```

Load it with `using DarOne`. Running the Fortran model also requires a Darwin3 source checkout, its [`dar_one_config` configuration](https://github.com/barbara42/dar_one_config), and a working Fortran/NetCDF toolchain. The [getting-started guide](https://daronemodel.github.io/DarOne.jl/build/getting_started/) explains how to prepare the model and run an experiment.

## Tutorials and examples

The repository contains a [beginner tutorial](beginner_tutorial/) and [case studies](case_studies/) for nutrient amendments, global steady states, and nitrogen fixation. To run these example scripts from a development checkout:

```bash
git clone https://github.com/DarOneModel/DarOne.jl.git
cd DarOne.jl
julia --project=. -e 'using Pkg; Pkg.instantiate()'
```

Prepare Darwin3 as described in the getting-started guide, then run `beginner_tutorial/1_build_example.jl` followed by `beginner_tutorial/2_run_example.jl`.

## Testing

The example integration tests compile and run Darwin3 and inspect diagnostic output. With the Fortran toolchain and Darwin3 checkout configured, run:

```bash
julia --project=. -e 'using Pkg; Pkg.test()'
```

## Development and attribution

Contributions are welcome through [GitHub pull requests](https://github.com/DarOneModel/DarOne.jl/pulls). DarOne incorporates code originally from [MITgcmTools.jl](https://github.com/gaelforget/MITgcmTools.jl), now developed as [MITgcm.jl](https://github.com/gaelforget/MITgcm.jl). The original copyright and MIT licence notice are retained in [LICENSE](LICENSE).
