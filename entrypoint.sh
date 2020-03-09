#!/bin/sh
set -o pipefail

# Create login user
if [ "${WEBCONSOLE_USER}" != "" ] && [ "${WEBCONSOLE_HASH}" != "" ] && [ "${WEBCONSOLE_SHELL}" != "" ]; then
  adduser -S -h "/home/${WEBCONSOLE_USER}" -s "${WEBCONSOLE_SHELL}" "${WEBCONSOLE_USER}"
  echo "${WEBCONSOLE_USER}:${WEBCONSOLE_HASH}" | chpasswd -e
fi

# Enable auto update of /etc/hosts by permanently
# watching for /webconsole/hosts
cp /etc/hosts /etc/hosts.backup
(
  while : ; do
    if [ -r /webconsole/hosts ]; then
      cat /etc/hosts.backup /webconsole/hosts > /etc/hosts
    fi
    sleep 1
  done
) &

unset WEBCONSOLE_USER
unset WEBCONSOLE_HASH

exec "$@"