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

#### Options

Certain actions inside the container will only work if it is running in `--privileged` mode, which is an option to `docker run`.

Examples of this include the `perf` profiling tool and the `setarch` tool that we use to control the executable loader. There seems to be little harm in using `--privileged`, but I typically leave it off by the Principle of Least Privilege.

#### Caveats

When you `docker run` a container and ultimately exit it, the changes you've made inside are effectively discarded.

For our workflow, we want to edit source files and retain output data outside the container.

Therefore I map a bunch of directories into the container using a docker feature called "bind-mount". The options I use to get this feature are displayed in the `Makefile`. So, for ordinary purposes, launch the container shell using `make launch_container_shell` (may need sudo).

Take a look at the options that are used there and you will see which directories are mapped through in that way. It may not include all the dirs you want. Feel free to map more: usually places where you have source files you're editing, or places you want to store output files permanently.

### Run examples

Once you're in the container, just run commands normally, except that things are located at /fiber-c and /wasmfxtime and so on, rather than in some deeper path. Here's an example command:

    /wasmfxtime/target/debug/wasmtime -W=stack-switching,function-references,exceptions /fiber-c/hello_wasmfx.wasm

There's also a "justfile" which allows you to run certain common command easily. Rather than remembering the above, I trigger it with

    just wasmtime /fiber-c/hello_wasmfx.wasm

which has the binary path and standard args built-in. You can add any additional args as needed. It will also print out the literal (expanded) command, which is useful for benchmarking, say in hyperfine, if you want to get `just` out of the critical path.

### Easy-go commands

Because there are lots of commands that are hard to remember (both for container building and for running wasm engines), I've been putting those commands into various files like Makefile and justfile. I hadn't decided which approach is better, but I think `justfile` is better since you can add arbitrary args to the commands. Look around for one of these files to see if there's something useful you need.