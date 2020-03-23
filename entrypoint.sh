#!/bin/ash
set -eo pipefail

echo "*** Start initialization ***"
# Create login user
if [ "${WEBCONSOLE_USER}" != "" ] && \
   [ "${WEBCONSOLE_HASH}" != "" ] && \
   [ "${WEBCONSOLE_SHELL}" != "" ]; then
  echo "Adding user '${WEBCONSOLE_USER}' with shell '${WEBCONSOLE_SHELL}'"
  adduser -D -h "/home/${WEBCONSOLE_USER}" -s "${WEBCONSOLE_SHELL}" "${WEBCONSOLE_USER}"

  echo "Changing password for user '${WEBCONSOLE_USER}'"
  echo "${WEBCONSOLE_USER}:${WEBCONSOLE_HASH}"|chpasswd -e

  sshdir="/home/${WEBCONSOLE_USER}/.ssh"
  echo "Creating directory ${sshdir}"
  mkdir -p "${sshdir}"
  chmod 700 "${sshdir}"
  chown "${WEBCONSOLE_USER}" "${sshdir}"
fi


# Enable auto update of /etc/hosts by permanently
# looking for /webconsole/*.hosts
if [ -r /webconsole/ ]; then
  echo "Starting hostkey-watcher"
  cp /etc/hosts /etc/hosts.backup
  (
    while : ; do
      cat /etc/hosts.backup /webconsole/*.hosts 2>/dev/null 1>/etc/hosts
      [ "${sshdir}" != "" ] && \
        cat /webconsole/*.hostkey 2>/dev/null 1>"${sshdir}"/known_hosts && \
        chown "${WEBCONSOLE_USER}" "${sshdir}"/known_hosts
      sleep 1
    done
  ) &
fi

unset WEBCONSOLE_USER
unset WEBCONSOLE_HASH

echo "*** Finished initialization ***"
exec "$@"