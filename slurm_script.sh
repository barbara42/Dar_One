#!/bin/sh
#SBATCH -J 33_2
#SBATCH -p sched_mit_darwin2    # which queue ("partition")
#SBATCH -N 6                    # number of nodes to use (each has 16 cores)
#SBATCH --constraint=centos7
#SBATCH --ntasks-per-node 16    # total number of cores to run on
#SBATCH --mem-per-cpu 8000      # memory per core needed (16-core nodes have 64GB)
#SBATCH --time 12:00:00         # run no longer than 16 hours
#SBATCH -x node[665-672]

module use /home/jahn/software/modulefiles

module load intel/2018-01
module load impi/2018-01
module load jahn/netcdf-fortran/4.4.5_intel-2018-01

julia experiments/periscope/n_vs_p_run.jl