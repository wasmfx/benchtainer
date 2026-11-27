#!/bin/bash

set -e

figlet ocaml
(cd ocaml-examples; ./bench.sh)
which figlet && figlet c
(cd fiber-c; analysis/bench.py)
which figlet && figlet kotlin
(cd kotlin-examples; ./bench.sh)

analysis/merge.sh  # Reconcile and tag data from all the languages into one pot.
analysis/plot_crosslang.py
