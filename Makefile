# This Makefile helps with building the container itself, or building things outside the container to then simply include in the container build.

# Not working yet
v8:
	export PATH=$(PATH):$(PWD)/depot_tools
	cd depot_tools
	gclient config
	gclient --verbose sync

go_itersum.wasm:
	GOOS=wasip1 GOARCH=wasm /usr/lib/go-1.23/bin/go build  -o /go-examples/itersum.wasm /go-examples/itersum.go

# Building the base V8 container should be necessary only when there are v8
# changes to pick up, which is rare. The other build ("container") will base
# itself on the V8 container and include that.
v8-base-container:
	docker build . -f v8.Dockerfile -t benchtainer-v8:latest

container:
	docker build . -t $(SUDO_USER)-benchtainer:latest

BIND_MOUNTS=--mount type=bind,src=$(PWD)/go-examples,dst=/go-examples --mount type=bind,src=$(PWD)/fiber-c/examples,dst=/fiber-c/examples --mount type=bind,src=$(PWD)/fiber-c/bench_results,dst=/fiber-c/bench_results --mount type=bind,src=$(PWD)/results,dst=/results

launch_container_shell launch:
	sudo docker run -it $(BIND_MOUNTS) $(USER)-benchtainer bash

launch_container_shell_privileged:
	sudo docker run --privileged -it $(BIND_MOUNTS) $(USER)-benchtainer bash


######## Stuff for building the Go examples outside the container. ########
#### TODO: Clean this up.

BINARYEN?=/opt/wasmfx/binaryenfx
WASM_INTERP?=/opt/wasmfx/specfx/interpreter/wasm
WASM_MERGE=$(BINARYEN)/bin/wasm-merge --enable-nontrapping-float-to-int --enable-multimemory --enable-exception-handling --enable-reference-types --enable-multivalue --enable-bulk-memory --enable-gc --enable-stack-switching

BASELINE_GO=/usr/lib/go-1.25/bin/go

CUSTOM_GO_ROOT=/go/src
ASM_WASM_FILE=$(CUSTOM_GO_ROOT)/runtime/asm_wasm

$(ASM_WASM_FILE).wasm: $(ASM_WASM_FILE).wat
	$(WASM_INTERP) -d -i $< -o $@ > out.log

%.wasm: %.pre.wasm $(ASM_WASM_FILE).wasm
	$(WASM_MERGE) $(@:.wasm=.pre.wasm) "main" $(ASM_WASM_FILE).wasm "wasmfx" -o $@

%.pre.wasm: %.go
	GOOS=wasip1 GOARCH=wasm /go/bin/go build -o $@ $<

%-baseline.wasm: %.go
	GOTOOLCHAIN=local GOOS=wasip1 GOARCH=wasm $(BASELINE_GO) build -o $@ $<
