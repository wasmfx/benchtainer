#!/bin/bash

set -e

(cd ocaml-examples; ./bench.sh)
(cd fiber-c; ./bench.py)
(cd kotlin-examples; ./bench.sh)
