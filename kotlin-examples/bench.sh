#!/bin/sh

set -ev

ROOT?=/opt/wasmfx
D8?=$ROOT/v8/v8/out/x64.release/d8

#######################
### Kotlin Baseline ###
#######################

cp build.gradle.kts-baseline build.gradle.kts
./gradlew build
${DB} --experimental-wasm-wasmfx \
  build/wasm/packages/kotlin-wasm-nodejs-example/kotlin/kotlin-wasm-nodejs-example.mjs \
  | sed '/benchmark/ s/$/,style/' \
  | sed '/benchmark/! s/$/,baseline/'

#######################
### Kotlin WasmFX   ###
#######################

cp build.gradle.kts-wasmfx build.gradle.kts
./gradlew build
${DB} --experimental-wasm-wasmfx \
  build/wasm/packages/kotlin-wasm-nodejs-example/kotlin/kotlin-wasm-nodejs-example.mjs \
  | sed '/benchmark/ s/$/,style/' \
  | sed '/benchmark/! s/$/,wasmfx/'
