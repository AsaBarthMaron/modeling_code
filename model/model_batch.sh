#!/bin/bash

# Be VERY careful here.
# Using mkdir with -p will mean that running this script
# will overwrite existing directory if it already exists.
saveDir="/Users/asa/Modeling/modeling_results/2019-03-08_first_run"
mkdir -p $saveDir

file="/Users/asa/Modeling/modeling_code/model/2019-03-08_first_run.txt"
echo $file


while IFS=',' read -r n1 n2
do
	sbatch submit.sh $n1 $n2 $saveDir
	sleep 1
done<"$file"