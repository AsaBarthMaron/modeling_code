#!/bin/sh
#SBATCH -p short
#SBATCH -t 3:00:00
#SBATCH --mem=16G
#SBATCH -c 6
#SBATCH --mail-user=jennylu2014@gmail.com
#SBATCH --mail-type=END

module load matlab/2017a
matlab -nodesktop -r "addpath('~/code/Functions')"
matlab -nodesktop -r "registration_routine('/n/scratch2/jl533/FSB_Data/${1}',${2},${3})"