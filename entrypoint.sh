#!/bin/sh
set -o pipefail

# Create login user
if [ "${WEBCONSOLE_USER}" != "" ] && [ "${WEBCONSOLE_HASH}" != "" ] && [ "${WEBCONSOLE_SHELL}" != "" ]; then
  adduser -S -h "/home/${WEBCONSOLE_USER}" -s "${WEBCONSOLE_SHELL}" "${WEBCONSOLE_USER}"
  echo "${WEBCONSOLE_USER}:${WEBCONSOLE_HASH}" | chpasswd -e
fi

unset WEBCONSOLE_USER
unset WEBCONSOLE_HASH

exec "$@"