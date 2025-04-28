#!/bin/sh
#This script runs the synthesizer on all files in the specified input dir.
inputs_dir="./tests/synth/test/"
#All outputs will be placed in the outputs_dir folder
outputs_dir="./outputs/"
#Runs in foreground or background
foreground=0


#Synthesizer related arguments
bitwidth=4
num_programs=100
num_iters=20
total_rounds=1250
program_length=40
solution_size=0
random_seed=2333
condition_length=10
num_abd_procs=50
abs_domain="KnownBits"
INIT_COST=11
INV_TEMP=200

for entry in "$inputs_dir"/*
do
  echo "$entry"
  filename=$(basename "${entry}")
  file_base_name="${filename%.*}"

  output_dir="${outputs_dir}${file_base_name}"
  mkdir -p "${output_dir}"

  cmd="synth-transfer ${entry} -num_programs ${num_programs} -total_rounds ${total_rounds} -num_iters ${num_iters} \
-condition_length ${condition_length} -solution_size ${solution_size} -num_abd_procs ${num_abd_procs} -weighted_dsl \
-random_seed ${random_seed} -bitwidth ${bitwidth} -program_length ${program_length} \
-outputs_folder ${output_dir} -domain ${abs_domain}"

  echo "$cmd"

  if [ "$foreground" -eq 1 ]; then
    eval "$cmd"
  else
    nohup $cmd > "${output_dir}/stdout.txt" 2>&1 &
  fi
done
