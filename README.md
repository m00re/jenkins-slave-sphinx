# Jenkins-Slave Docker-Image

A Jenkins-Slave Docker image including Sphinx, Breathe and Doxygen pre-installed.

## Available Docker Images at DockerHub

Image Name                    | Tag   | Sphinx | Jinja2 | Breathe | Doxygen
------------------------------|-------|--------|--------|---------|--------
m00re/jenkins-slave-sphinx    | 1.6.3 | 1.6.3  | 2.9.6  | 4.7.1   | 1.8.5-3

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
  m00re/jenkins-slave-sphinx:1.6.3
```

to spawn a new Jenkins slave docker container with ```2 executors```, Jenkins labels ```doxygen``` and ```sphinx```, using the Jenkins credentials ```slave/slave```, and connecting to a Jenkins master instance running at ```http://yourjenkinsmasterurl:8080/```.

> **NOTE: Please be aware that the above example uses HTTP to connect your slave node to the master node. This is not recommended. Instead, use a setup as provided below, in which master and slave nodes are linked over a virtual private Docker network.**

## Acknowledgements

A huge thank you goes to [blacklabelops](https://github.com/blacklabelops/) for his Dockerfile recipes in https://github.com/blacklabelops/swarm/tree/master/hashicorp-virtualbox and https://github.com/blacklabelops/jenkins-swarm. His scripts served as the starting point for the above image.
