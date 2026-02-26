FROM ubuntu:resolute

RUN apt-get update

RUN apt-get install -y make curl wget cmake git g++-multilib ocaml-dune ocaml menhir opam rustup

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
RUN cargo build

## Build fiber-c

COPY fiber-c /fiber-c
WORKDIR /fiber-c
RUN make

# sudo docker run -d d8ef44b1d61b tail -f /dev/null

# sudo docker exec <id> ../wasmfxtime/target/debug/wasmtime run -W=exceptions,function-references,stack-switching hello_wasmfx.wasm