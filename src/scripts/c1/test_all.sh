#!/bin/sh

result_dir="result_text.txt"
cd "/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl/src/scripts/c1/"
for idx in $(seq 1 1);
do
    julia --project='/home/jxxiong/A-xjx/PowerModelsSecurityConstrained.jl' test_all.jl --start "$idx" --end "$idx" --result_dir "$result_dir" --second_stage &>"logs/approx.log"
done