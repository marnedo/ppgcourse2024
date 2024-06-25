## This is a quick-guide on how to get and run the Docker image that contains the command-line software requested by instructors. 

You can use it to test on your own computer programs and data you intend to use in your computer lab sessions. 

You will need a computer with an operating system (Host OS) able to run Docker:

https://docs.docker.com/engine/docker-overview/

---

### 1. Install Docker:

https://docs.docker.com/get-docker/

> remember to use ‘sudo’ for administrative commands if you are not logged in as the root in your computer


---

### 2. Get the docker image from our Docker Hub repository (you may need to prepend ‘sudo’ before any docker command if you are using Linux):

We have built and tested our image primarily using Ubuntu Linux as Host OS.

`docker pull ppgcourseub/ppg2024:2406-r01`

This will take a while, depending on the speed of your internet connection.

After it's finished, you should see listed the downloaded image using this:

`docker images`

---

### 3. Run a container from the downloaded image

`docker run -it --name=container_name 9c539d570554 /bin/bash` 

> NOTE: The string ‘9c539d570554’ is the “name” (id, more properly) of the image you got at step 1. This name may be different on your computer
> (it depends on the Docker version). Check the correct name on the listing from the `docker images` command. The expression after '--name=' is
> the name of the new container. You can replace it with any other name you prefer.

After running the previous command, you will see a new prompt symbol on your terminal (starting by 'ppguser@' follower by an arbitrary ID string). You are now running a new Docker container. 

Think of a container as an instance of a Docker image. Your new container is running Ubuntu, and now you can run any of the installed programs on it.

You can exit your new running container at any time, mainly in two ways:
- Typing `exit`. This will also stop the container.
- Typing the sequence ctrl+p, ctrl+q. In this case the container will continue to run after you exit.

You can list all your containers with:

`docker ps -a`

You can check if a container is currently running or stopped from the same listing.

---

### 4. Re-connecting to your container:

If you stopped your container, first type:

`docker start container_name`

(replace 'container_name' with the name of your container)

And then type:

`docker exec -it container_name /bin/bash`

The command prompt of your container will appear again.

If your container is already running you can re-connect to it again with the previous command (docker exec ...) at any time.

> Note: there are other ways of re-attaching to your container, this is just one)

---

### 5. Additional info: Running your container with  a 'shared' data directory

One of the most practical ways to make the data files you need to run your programs available to your container is to SET A “SHARED DIRECTORY” between your host OS and the container. All the data you put in that directory on your Host OS will be available also in the linked directory of your running container. Conversely, all the data you store in the linked container directory will be available in your Host OS corresponding directory. 

If you want to use this configuration, replace the initial 'docker run...' command of section 3 with this one:

* In Linux:

docker run -it –name=container_name -v /home/username/ppgdata:/ppgdata 9c539d570554 /bin/bash

* In Mac:

d docker run -it –name=container_name v /Users/username/ppgdata:/ppgdata 9c539d570554 /bin/bash

> NOTE: The string ‘9c539d570554’ is the “name” (id, more properly) of the image you got at step 1.
> This name may be different on your computer (it depends on the Docker version). Check the correct name on the listing from the ‘docker images’ command.
> Remember that the value after ‘--name=’ sets the name of the new running container. If you already created other container with the same name (from a previous docker run… command for example), you will get an error. To solve it, either change the name of the new container or remove (see below, section ‘Other useful commands’) the existing one with the conflicting name before creating the new one]

The difference here is the `-v` parameter, which creates a 'link' between the Host OS directory '/home/username/ppgdata' (or '/Users/username/ppgdata') and the container directory '/ppgdata'. To avoid permission problems inside your container, grant full read and write permissions on your Host OS directory (‘/home/username/ppgdata’ or 'Users/username/ppgdata' in this example) to all users. For example, on linux:

`chmod 777 /home/username/ppgdata`

After this, anything you put in the '/home/username/ppgdata' directory of your computer Host OS will be available immediately at the '/ppgdata' directory of your container, and also the other way around. This is a convenient and simple way of providing data files to use with your programs and also to get results data out from your container to your host OS.

This is the preferred way we will be using at the computers lab to share data between the student’s computer OS and the containers running on them.

---

### Other useful commands:

To remove images:

`docker images`

`docker rmi imageid`

To remove containers:

`docker ps -a`

`docker rm container_name`

> Stop the container if it is running: `docker stop container_name`, not necessary otherwise.






