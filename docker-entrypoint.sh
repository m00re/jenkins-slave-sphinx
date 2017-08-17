#!/bin/bash

set -o errexit

# Step 1: dynamically create user
USER_ID=${RUN_WITH_USER_ID:-1000}
GROUP_ID=${RUN_WITH_GROUP_ID:-1000}

echo "Starting with UID/GID : $USER_ID/$GROUP_ID"
/usr/sbin/groupadd --gid $RUN_WITH_GROUP_ID swarm && \
/usr/sbin/useradd --uid $RUN_WITH_USER_ID --gid $RUN_WITH_GROUP_ID --shell /bin/bash -d $SWARM_HOME swarm

chown -R swarm:swarm $SWARM_HOME $SWARM_WORKDIR
chmod +x $SWARM_HOME/swarm-client.jar

export HOME=$SWARM_HOME

# Step 2: import ssh keys
if [ -d "$IMPORT_HOME_FROM" ]; then
  echo "Importing files and directories from $IMPORT_HOME_FROM into $SWARM_HOME"
  for f in "$IMPORT_HOME_FROM"/* "$IMPORT_HOME_FROM"/.*; do
    # do not handle ".", "..", and "*" result
    if [ "$f" != "$IMPORT_HOME_FROM/." ] && [ "$f" != "$IMPORT_HOME_FROM/.." ] && [ "$f" != "$IMPORT_HOME_FROM/*" ]; then
      cp -rvf $f $SWARM_HOME/
    fi
  done
  chown -R swarm:swarm $SWARM_HOME
fi

# Step 3: run Jenkins (or just the provided command)
if [ "$1" = 'swarm' ]; then
  exec /usr/bin/gosu swarm $SWARM_HOME/run-jenkins.sh "$@"
elif [[ "$1" == '-'* ]]; then
  exec /usr/bin/gosu swarm $SWARM_HOME/run-jenkins.sh "$@"
else
  exec "$@"
fi