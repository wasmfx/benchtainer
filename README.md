# benchtainer

This is a Docker container that includes all the software needed to build fiber-c examples and run them with wasmfxtime. It should be able to build those things from the form they're in in their respective git repos, and give you a completely compiled artifact, the Docker image, which you can then just start up and use.

It's not intended that it should be limited to fiber-c examples. Maybe we'll want to grow this to other source languages and Wasm producers.

## Usage

If you already have a built Docker image, skip to "Use the Image" below.

### Prereqs

### Build the Image

To build the container image, run `sudo docker build .`

This will produce an image that's in your local docker installation's registry. It is identified by a hash, or you can attach a mnemonic, versioned tag by building with `-t tag:version`.

To see what images you have locally, run `sudo docker images`.

### Use the Image

Using the hash of the image, you can start up a container using

    sudo docker run -d <hash> tail -f /dev/null

(The "tail -f /dev/null" is the primary command we're asking it to run in the container; we're choosing this because it doesn't exit and we want our container to start up and sit around so we can run experiments in it.

The above command will give you a new hash, which is that of the running container invocation; you'll use that next. (This invocation is what is called a "container" as opposed to the "container image" that we build earlier.)

Now you can run a command using

    sudo docker exec <running-hash> <cmd>

Or you can enter a shell like this:

    sudo docker exec -i <running-hash> bash

(The shell experience turns out to be crap; TODO: look into how to get a better shell experience.)

If you forget the hash or name of the running container, you can use

    sudo docker ps

Note each one has a generated name of two words like flamboyant_beaver or agitated_benz. You can use that instead of the hash.

Destroy one you're done with using

    sudo docker kill <running-hash>
    
### Run examples

So here's an example fiber-c run, if the container you've created is called "flamboyant_beaver":

    sudo docker exec flamboyant_beaver ../wasmfxtime/target/debug/wasmtime -W=stack-switching,function-references,exceptions /fiber-c/hello_wasmfx.wasm