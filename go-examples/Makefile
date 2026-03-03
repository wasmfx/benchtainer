%.wasm: %.go
	GOOS=wasip1 GOARCH=wasm /usr/lib/go-1.23/bin/go build -o $@ $<
