#!/bin/bash

# Be VERY careful here.
# Using mkdir with -p will mean that running this script
# will overwrite existing directory if it already exists.
saveDir="$HOME/Modeling/modeling_results/2019-03-13_minimal_con_type_param_sweep"
mkdir -p $saveDir

file="$HOME/Modeling/modeling_results/runtime_arguments/2019-03-13_minimal_con_type_param_sweep.txt"
echo $file


while IFS=',' read -r n1 n2 n3 n4 n5 n6 n7 n8 n9 n10 n11 
do
	sbatch submit.sh $n1 $n2 $n3 $n4 $n5 $n6 $n7 $n8 $n9 $n10 $n11 $saveDir
	sleep 1
done<"$file"