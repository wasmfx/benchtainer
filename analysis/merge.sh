#!/bin/bash

# Grab a representative CSV header (hoping they're all the same!)
sed -n '1p' fiber-c/bench_results/results/results_*.csv | sed 's/$/,language/' > tmp/c-results.csv
# Grab the data from following the 1st line.
for file in fiber-c/bench_results/results/results_*.csv
do
sed '1d' $file \
  | sed '/parameter_style/! s/$/,c/' >> tmp/c-results.csv
done

echo "benchmark,engine,style,mean,median,min,max,language" > tmp/ocaml-results.csv
jq .results.[] ocaml-examples/results/*.json \
  | jq --raw-output '[.parameters.benchmark, .parameters.engine, .parameters.style, .mean, .median, .min, .max, "ocaml"] | @csv' \
  >> tmp/ocaml-results.csv
