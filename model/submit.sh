#!/bin/sh
#SBATCH -p short
#SBATCH -t 12:00:00
#SBATCH --mem=2G
#SBATCH -c 4
#SBATCH --mail-user=asabarthmaron@gmail.com
#SBATCH --mail-type=END

module load matlab/2018a
matlab -nodisplay -r "cd /home/anb12/Modeling/modeling_code/model; run_model_O2($1, $2, $3)"