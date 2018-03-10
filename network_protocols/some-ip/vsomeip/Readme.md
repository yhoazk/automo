# Some/IP test application


The goal is to have a pair of docker cointainers communicating with some/ip
each other.




## Docker Commands:

List all containers in PC:
```
docker ps -a
```

Remove containers with status == exited, (closed containers)
```
docker rm $(docker ps -a -q -f status=exited)
```

Delete the container once it's exited:
```
docker run --rm -it <cont_id>
```

Detach a container (run -d):
<br>  A detached container releases the terminal, and then, to be stopped use `stop`
```
docker run -d <image>
```

Stop a detached container:
```
docker stop <container_id>
```

## [Dockerfile](https://docs.docker.com/engine/reference/builder/)

A Dockerfile is a text file that contains a list of commands that the docker
client calls while creating an image. It is used to automate the image creation
process.

Dockerfile commands:

ENTRYPOINT:
An entry point allows to configure a container that will run as an executable.
The syntax of the command is a JSON array with the command and its parameters
```
ENTRYPOINT ["executable", "param1", "param2"]
```

## [.dockerignore](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/#use-a-dockerignore-file)

When issuing a command `docker build` the current directory is called the
*build context* and all the contents (recursively) of the current directory are
sent to the docker daemon as the *build context*. Then files that are not needed
for the image to work, only delay the `save`, `pull` and `push` and also the runtime
size of the container.


The concept is similar to the `.gitignore` file, in the `.dockerignore` just add
the files that are not relevant to the build


### Jargon:

**Image**: blueprint of the application, basis of a container.<br>
**container**: Created from a docker image, created with `docker run` command
