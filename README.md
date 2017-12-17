# Jenkins-Slave Docker-Image

A Jenkins-Slave Docker image including Sphinx, Breathe and Doxygen pre-installed.

## Available Docker Images at DockerHub

Image Name                    | Tag     | Sphinx | Jinja2 | Breathe | Doxygen | Swarm Client
------------------------------|---------|--------|--------|---------|-----------------------
m00re/jenkins-slave-sphinx    | 1.6.3-2 | 1.6.3  | 2.9.6  | 4.7.1   | 1.8.5-3 | 3.6
m00re/jenkins-slave-sphinx    | 1.6.3   | 1.6.3  | 2.9.6  | 4.7.1   | 1.8.5-3 | 3.4

See: https://hub.docker.com/r/m00re/jenkins-slave-sphinx/

## Building

Simply type ```docker build . -t <YourTagName>``` to rebuild the image yourself. 

## Usage

Simply type

```
docker run \
  -e "SWARM_VM_PARAMETERS=" \
  -e "SWARM_MASTER_URL=http://yourjenkinsmasterurl:8080/" \
  -e "SWARM_VM_PARAMETERS=" \
  -e "SWARM_JENKINS_USER=slave" \
  -e "SWARM_JENKINS_PASSWORD=slave" \
  -e "SWARM_CLIENT_EXECUTORS=2" \
  -e "SWARM_CLIENT_LABELS=doxygen sphinx" \
  -e "SWARM_CLIENT_NAME=" \
  m00re/jenkins-slave-sphinx:1.6.3-2
```

to spawn a new Jenkins slave docker container with ```2 executors```, Jenkins labels ```doxygen``` and ```sphinx```, using the Jenkins credentials ```slave/slave```, and connecting to a Jenkins master instance running at ```http://yourjenkinsmasterurl:8080/```.

> **NOTE: Please be aware that the above example uses HTTP to connect your slave node to the master node. This is not recommended. Instead, use a setup as provided below, in which master and slave nodes are linked over a virtual private Docker network.**

## Advanced configuration

This Docker image provides additional configuration options. By default, the container will create a new user and a new 
group called ```swarm``` inside of the Docker container, using the default user and group IDs ```1000```. To override the
 IDs, simply use the environment variables ```RUN_WITH_USER_ID``` and ```RUN_WITH_GROUP_ID```.
 
In addition, it is possible to inject / populate the home directory of the ```swarm``` user with settings from the host
machine. If the environment variable ```IMPORT_HOME_FROM``` is set and pointing to a host-mounted volume that includes
files and directories, all of these files and directories will be copied to the home directory of the ```swarm``` user
and owner-changed accordingly. For instance, the following command will import all files from /root/.ssh/ into the home
directory of the ```swarm``` user.

```bash
$ sudo docker run -e IMPORT_HOME_FROM=/inject -v /root/.ssh/:/inject/.ssh:Z -it m00re/jenkins-slave-sphinx:1.6.3-2
```

## Acknowledgements

A huge thank you goes to [blacklabelops](https://github.com/blacklabelops/) for his Dockerfile recipes in https://github.com/blacklabelops/swarm/tree/master/hashicorp-virtualbox and https://github.com/blacklabelops/jenkins-swarm. His scripts served as the starting point for the above image.
