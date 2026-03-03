# This Makefile helps with building the container itself, or building things outside the container to then simply include in the container build.

# Not working yet
v8:
	export PATH=$(PATH):$(PWD)/depot_tools
	cd depot_tools
	gclient config
	gclient --verbose sync

container:
	docker build . -t $(SUDO_USER)-benchtainer:latest

launch_container_shell:
	sudo docker run -it --mount type=bind,src=$PWD/go-examples,dst=/go-examples $(USER)-benchtainer bash

# Note for benchmarking purposes we launch the container with --privileged which allows the `perf` tool to run inside.
launch_container_daemon:
	sudo docker run -d --privileged benchtainer tail -f /dev/null
