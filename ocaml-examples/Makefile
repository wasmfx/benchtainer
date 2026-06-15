all: bin/itersum.byte bin/itersum_wasmfx.js bin/itersum_cps.js bin/treesum.byte bin/treesum_wasmfx.js bin/treesum_cps.js bin/pi.byte bin/pi_wasmfx.js bin/pi_cps.js bin/scheduler.byte bin/scheduler_wasmfx.js bin/scheduler_cps.js

bin/%.byte: bin/%.ml
	ocamlfind ocamlc -package js_of_ocaml -package js_of_ocaml-ppx -linkpkg -o $@ $<
# ocamlc -package ~/wasmfx/js_of_ocaml/_build/default/compiler/bin-js_of_ocaml/js_of_ocaml.exe -package ~/wasmfx/js_of_ocaml/_build/default/ppx/ppx_js/bin/main.exe -linkpkg -o $@ $<

bin/%_wasmfx.js: bin/%.byte
	~/wasmfx/js_of_ocaml/_build/default/compiler/bin-wasm_of_ocaml/wasm_of_ocaml.exe --effects=native -o $@ $<

bin/%_cps.js: bin/%.byte
	~/wasmfx/js_of_ocaml/_build/default/compiler/bin-wasm_of_ocaml/wasm_of_ocaml.exe --effects=cps -o $@ $<

.PHONY: clean
clean:
	rm -f bin/*.cmi
	rm -f bin/*.cmo
	rm -f bin/*.byte
	rm -f bin/*.js
	rm -rf bin/*.assets