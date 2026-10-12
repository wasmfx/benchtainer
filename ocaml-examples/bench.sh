# dune doesn't seem to support building different executables from the same source file, so we will painstakingly
# copy the executables to different directories and run them from there.

# Engines and corresponding wasm_of_ocaml flags
declare -A engine_flags=(
    [d8]=""
    [wasmtime]="--enable wasi "
)

# Compilation styles and corresponding wasm_of_ocaml flags
declare -A style_flags=(
    [cps]="--effects=cps --opt=3"
    [wasmfx]="--effects=native --opt=3"
)

python3 build.py

for engine in "${!engine_flags[@]}"; do
  for style in "${!style_flags[@]}"; do
    mkdir -p $engine\_$style
    # Copy the contents of `bin` to each new directory
    cp -r bin/*.ml $engine\_$style
    # Add a dune file to that directory
    cp dune_template $engine\_$style/dune
    # Edit the dune file to use the right compilation flags
    sed -i "s/<FLAGS>/${engine_flags[$engine]}${style_flags[$style]}/" $engine\_$style/dune
  done
done

export PATH="/opt/wasmfx/binaryen/bin:$PATH"
source ~/.bashrc
dune build

# Run benchmarks for each of the executables in their respective directories
cd _build/default

for engine in "${!engine_flags[@]}"; do
  for style in "${!style_flags[@]}"; do
    cd $engine\_$style
    hyperfine --warmup 1 --runs 2 --export-json ../../../results/results_$engine\_$style.json -L benchmark itersum treesum -L engine $engine -L style $style ../../../run-scripts/{benchmark}_{engine}.sh
    cd ..
  done
done

python3 ../../plot_benchmarks.py results/* --benchmarks itersum treesum --engines d8 wasmtime

# Clean up
dune clean
rm -rf d8_cps d8_wasmfx wasmtime_cps wasmtime_wasmfx run-scripts