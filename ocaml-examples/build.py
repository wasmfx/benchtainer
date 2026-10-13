#!/usr/bin/env python3
"""
Buildscript that generates scripts to run them on the three wasm engines of interest (d8, wasmtime, and wizard).
The generated scripts are in /run-scripts and can be executed with `./run-scripts/benchmark_engine.sh`,
e.g. `./run-scripts/sieve1_d8_wasmfx.sh`. Configurations are in config.yml.

Usage:  `./build.py`
"""

import yaml
import os
from pathlib import Path

# Import config
config = yaml.safe_load(open("config.yml"))

# Set up environment variables for directory containing engines, defaulting to `/opt/wasmfx`` if not set
ENGINE_ROOT_DIR = os.getenv("ENGINE_ROOT_DIR", "/opt/wasmfx")

# ---- Script generation ----

SCRIPT_TEMPLATE = f"#!/bin/bash\nsetarch -R {{engine_path}} {{engine_options}}"

def make_script(filename: Path, content: str):
    filename.write_text(content)
    filename.chmod(0o755)

def generate_scripts(benchmark: str, engines: list[str]):
    Path("run-scripts").mkdir(exist_ok=True)

    # Generate scripts that run each benchmark using SCRIPT_TEMPLATE and data from config.yml
    for engine in engines:
        script_name = f"{benchmark}_{engine}.sh"
        # configure engine-specific options
        match engine:
            case "wasmtime":
                engine_path=config["WASMTIME_PATH"]
                engine_options=config["WASMTIME_OPTIONS"].replace("<BENCHMARK>", str(benchmark))
            case "wizard":
                engine_path=config["WIZARD_PATH"]
                engine_options=config["WIZARD_OPTIONS"].replace("<BENCHMARK>", str(benchmark))
            case "d8":
                engine_path=config["D8_PATH"]
                engine_options=config["D8_OPTIONS"].replace("<BENCHMARK>", str(benchmark))
        # stick this all into the script template
        content = SCRIPT_TEMPLATE.format(
            engine_path=ENGINE_ROOT_DIR + engine_path,
            engine_options=engine_options,
            benchmark=benchmark,
        )
        make_script(Path("run-scripts/" + script_name), content)

def main():
    for benchmark in config["BENCHMARKS_FIBER_C"]:
        generate_scripts(benchmark, config["ENGINES"])
        print("Generated scripts for benchmark:", benchmark)

if __name__ == "__main__":
    main()
