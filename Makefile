# This Makefile helps with building the container itself, or building things outside the container to then simply include in the container build.

# Not working yet
v8:
	export PATH=$(PATH):$(PWD)/depot_tools
	cd depot_tools
	gclient config
	gclient --verbose sync

go_itersum.wasm:
	GOOS=wasip1 GOARCH=wasm /usr/lib/go-1.23/bin/go build  -o /go-examples/itersum.wasm /go-examples/itersum.go

container:
	docker build . -t benchtainer:latest

launch_container_shell:
	sudo docker run -i benchtainer /bin/bash

# Note for benchmarking purposes we launch the container with --privileged which allows the `perf` tool to run inside.
launch_container_daemon:
	sudo docker run -d --privileged benchtainer tail -f /dev/null
