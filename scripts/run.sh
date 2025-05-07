#!/bin/bash
#This script runs the synthesizer on all files in the specified input dir.
inputs_dir="./tests/synth/knownBits/"
#All outputs will be placed in the outputs_dir folder
outputs_dir="./outputs/knownBits/"
#KnownBits or ConstantRange
abs_domain="KnownBits"
#Runs in foreground or background
foreground=0
# Set to 1 to only run representative entries
run_representatives_only=1

# List of representative entry base names (no .mlir extension)
representatives=(
  "knownBitsAnd"
  "knownBitsAdd"
  "knownBitsUmax"
  "knownBitsSmax"
  "knownBitsShl"
  "knownBitsLshr"
  "knownBitsMul"
  "knownBitsUdiv"
  "knownBitsAvgFloorU"
  "knownBitsAddNuw"
  "knownBitsAddNsw"
  "knownBitsShlNuw"
  "knownBitsShlNsw"
  "knownBitsLshrExact"
)

#Synthesizer related arguments
bitwidth=4
num_programs=100
num_iters=10
total_rounds=2500
program_length=28
solution_size=0
random_seed=2333
condition_length=10
num_abd_procs=50


for entry in "$inputs_dir"/*
do
  case "$entry" in
    *.mlir) ;;  # pass
    *) continue ;;  # skip non-.mlir files
  esac

  filename=$(basename "${entry}")
  file_base_name="${filename%.*}"

  if [ "$run_representatives_only" -eq 1 ]; then
    found=0
    for rep in "${representatives[@]}"; do
      if [ "$file_base_name" = "$rep" ]; then
        found=1
        break
      fi
    done
    if [ "$found" -eq 0 ]; then
      continue
    fi
  fi

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
