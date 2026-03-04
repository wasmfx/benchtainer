FROM ubuntu:questing

RUN apt-get update

# For golang, 1.23 is the first version that supports generators in the language.
RUN apt-get install -y make curl wget cmake git g++-multilib ocaml-dune ocaml menhir opam rustup hyperfine linux-tools-generic golang-1.23

## Unpack wasi-sdk

## curl doesn't work for some reason (0 bytes return). So I use wget.
# RUN curl -O https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-30/wasi-sdk-30.0-x86_64-linux.tar.gz
RUN wget https://github.com/WebAssembly/wasi-sdk/releases/download/wasi-sdk-30/wasi-sdk-30.0-x86_64-linux.tar.gz
RUN tar xzf wasi-sdk-30.0-x86_64-linux.tar.gz

## build binaryen

COPY binaryen /binaryen
WORKDIR /binaryen
# RUN CC=../wasi-sdk-30.0-x86_64-linux/bin/clang cmake . && make
RUN CXX=g++ CC=gcc cmake . && CXX=g++ CC=gcc make -j12

## Build custom (stack-switching) version of reference interpreter

## opam is needed for the reference interpreter build
# Disable-sandboxing was recommended here for use inside Docker containers: https://github.com/ocaml/opam/issues/4327#issuecomment-678630182
RUN opam init --yes --disable-sandboxing
RUN opam install --yes js_of_ocaml-compiler js_of_ocaml-ppx

## Build ref interpreter

COPY stack-switching /stack-switching
WORKDIR /stack-switching/interpreter
RUN eval $(opam env) make

## Build wasm(fx)time

COPY wasmfxtime /wasmfxtime
WORKDIR /wasmfxtime
RUN rustup update 1.82.0   # version that wasmfxtime is written to.
RUN cargo build --release  # Note --release, without which we get the debug build, not good for benching.

## Virgil

COPY virgil /virgil
WORKDIR /virgil
RUN PATH=$PATH:/virgil/bin make

## Wizard

COPY wizard-engine /wizard-engine
WORKDIR /wizard-engine
RUN PATH=$PATH:/virgil/bin make -j
COPY run-virgilly /run-virgilly

## Build fiber-c

COPY fiber-c /fiber-c
WORKDIR /fiber-c
RUN make

COPY go-examples /go-examples

ADD contents/Makefile /Makefile
ADD contents/run_and_log.sh /run_and_log.sh
WORKDIR /

## Create a python virtual environment and dependencies of our test driver script.

RUN apt install -y python3-venv
RUN python3 -m venv /venv
RUN /venv/bin/pip install pyyaml matplotlib numpy

## (it would be nice to have a generic hole in the floor of the container to edit files locally and see them in the container.)
# RUN --mount=type=bind,target=examples,rw

## To start up the container:

# sudo docker build .
# sudo docker run -d <hash> tail -f /dev/null
# sudo docker exec <instance-hash> ../wasmfxtime/target/debug/wasmtime run -W=exceptions,function-references,stack-switching hello_wasmfx.wasm

## Interesting perf command to run:
# sudo docker exec heuristic_golick perf stat ../wasmfxtime/target/debug/wasmtime run -W=exceptions,function-references,stack-switching itersum_wasmfx.wasm 20000000

## For wizard:
# /wizard-engine/bin/wizeng.x86-64-linux --ext:stack-switching /fiber-c/itersum_wasmfx.wasm 20000000
