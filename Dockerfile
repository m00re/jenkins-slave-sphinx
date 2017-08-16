FROM centos:7.3.1611
MAINTAINER Jens Mittag <kontakt@jensmittag.de>

# Jenkins Swarm Version
ARG SWARM_VERSION=3.4
ARG SWARM_SHA=ef74404b14710491ca7e416bb9bed29f7f5236db

# Tini Zombie Reaper and Signal Forwarder Version
ARG TINI_VERSION=0.13.2
ARG TINI_SHA=afbf8de8a63ce8e4f18cb3f34dfdbbd354af68a1

# Container User
ARG CONTAINER_USER=jenkins
ARG CONTAINER_UID=1000
ARG CONTAINER_GROUP=jenkins
ARG CONTAINER_GID=1000

# Container Internal Environment Variables
ENV SWARM_HOME=/opt/jenkins-swarm \
    SWARM_WORKDIR=/opt/jenkins

# Create user
RUN /usr/sbin/groupadd --gid $CONTAINER_GID $CONTAINER_GROUP && \
    /usr/sbin/useradd --uid $CONTAINER_UID --gid $CONTAINER_GID --shell /bin/bash $CONTAINER_USER

# Install Development Tools
RUN yum install -y \
      unzip \
      tar \
      gzip \
      wget \
      nano \
      git \
      doxygen \
      make \
      java-1.8.0-openjdk-headless

# Install Tini Zombie Reaper And Signal Forwarder
RUN curl -fsSL https://github.com/krallin/tini/releases/download/v${TINI_VERSION}/tini-static-amd64 -o /bin/tini && chmod +x /bin/tini \
  && echo "$TINI_SHA  /bin/tini" | sha1sum -c -

# Install Jenkins Swarm-Slave
RUN mkdir -p ${SWARM_HOME} && \
    wget --directory-prefix=${SWARM_HOME} \
      https://repo.jenkins-ci.org/releases/org/jenkins-ci/plugins/swarm-client/${SWARM_VERSION}/swarm-client-${SWARM_VERSION}.jar && \
    sha1sum ${SWARM_HOME}/swarm-client-${SWARM_VERSION}.jar && \
    echo "$SWARM_SHA ${SWARM_HOME}/swarm-client-${SWARM_VERSION}.jar" | sha1sum -c - && \
    mv ${SWARM_HOME}/swarm-client-${SWARM_VERSION}.jar ${SWARM_HOME}/swarm-client.jar && \
    mkdir -p ${SWARM_WORKDIR} && \
    chown -R ${CONTAINER_USER}:${CONTAINER_GROUP} ${SWARM_HOME} ${SWARM_WORKDIR} && \
    chmod +x ${SWARM_HOME}/swarm-client.jar

# Install Sphinx
RUN yum -y install epel-release && \
    yum install -y python2-pip && \
    pip install --upgrade pip && \
    pip install sphinx && \
    pip install breathe

# Cleanup yum
RUN yum clean all && rm -rf /var/cache/yum/*

# Entrypoint Environment Variables
ENV SWARM_VM_PARAMETERS= \
    SWARM_MASTER_URL= \
    SWARM_VM_PARAMETERS= \
    SWARM_JENKINS_USER= \
    SWARM_JENKINS_PASSWORD= \
    SWARM_CLIENT_EXECUTORS= \
    SWARM_CLIENT_LABELS= \
    SWARM_CLIENT_NAME=

USER $CONTAINER_USER
WORKDIR $SWARM_WORKDIR
VOLUME $SWARM_WORKDIR
COPY docker-entrypoint.sh ${SWARM_HOME}/docker-entrypoint.sh
ENTRYPOINT ["/bin/tini","--","/opt/jenkins-swarm/docker-entrypoint.sh"]
CMD ["swarm"]
