#!/bin/bash

# Be VERY careful here.
# Using mkdir with -p will mean that running this script
# will overwrite existing directory if it already exists.
saveDir="$HOME/Modeling/modeling_results/2019-03-12_steps_debugging"
mkdir -p $saveDir

file="$HOME/Modeling/modeling_results/runtime_arguments/2019-03-11_steps_debugging.txt"
echo $file


while IFS=',' read -r n1 n2
do
	sbatch submit.sh $n1 $n2 $saveDir
	sleep 1
done<"$file"