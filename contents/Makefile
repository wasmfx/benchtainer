# This Makefile goes inside the container, to give us easy things to run inside.

FEATURES=-W=exceptions,function-references,stack-switching
WASMTIME=/wasmfxtime/target/release/wasmtime

%.cwasm: %.wasm
	$(WASMTIME) compile $(FEATURES) $< -o $@

go-examples/%.cwasm: go-examples/%.wasm
	$(WASMTIME) compile $(FEATURES) $< -o $@

perf_stat_go_compiled_itersum:
	perf stat $(WASMTIME) run $(FEATURES) --allow-precompiled /go-examples/itersum.cwasm 20 20

perf_stat_go_itersum:
	perf stat $(WASMTIME) run $(FEATURES) --allow-precompiled /go-examples/itersum.wasm 20 20
