# benchtainer

This is a Docker container that includes all the software needed to build fiber-c examples and run them with wasmfxtime. It should be able to build those things from the form they're in in their respective git repos, and give you a completely compiled artifact, the Docker image, which you can then just start up and use.

It's not intended that it should be limited to fiber-c examples. Maybe we'll want to grow this to other source languages and Wasm producers.

## Usage

If you already have a built Docker image, skip to "Use the Image" below.

### Prereqs

Initialize the git submodules using

    git submodule init
    git submodule update --init --recursive

### Build the Image

To build the container image, run `sudo docker build . -t $USER-benchtainer:latest`

This will produce an image that's in your local docker installation's registry. It is identified by a hash, or the tag name given (I.e. "ezra-benchtainer". The "latest" is a version that's not essential when identifying it.)

The username is added as a convention for our group since we are usually working on a shared machine and this tag space is shared. Feel free to choose another reasonable name if you like.

To see what images you have locally, run `sudo docker images`.

### Use the Image

Start a container into a shell using

    sudo docker run -it <image> bash

The <image> is either the hash reported when you built it, or a tag like `benchtainer`.

### Run examples

Once you're in the container, just run commands normally, except that things are located at /fiber-c and /wasmfxtime and so on, rather than in some deeper path. Here's an example command:

    /wasmfxtime/target/debug/wasmtime -W=stack-switching,function-references,exceptions /fiber-c/hello_wasmfx.wasm

There's also a "justfile" which allows you to run certain common command easily. Rather than remembering the above, I trigger it with

    just wasmtime /fiber-c/hello_wasmfx.wasm

which has the binary path and standard args built-in. You can add any additional args as needed. It will also print out the literal (expanded) command, which is useful for benchmarking, say in hyperfine, if you want to get `just` out of the critical path.