#!/bin/sh
set -o pipefail

# Create login user
[ "${WEBCONSOLE_USER}" != "" -a "${WEBCONSOLE_HASH}" != "" -a "${WEBCONSOLE_SHELL}" != "" ] && \
  adduser -h /home/"${WEBCONSOLE_USER}" -s "${WEBCONSOLE_SHELL}" "${WEBCONSOLE_USER}" && \
  echo "${WEBCONSOLE_USER}:${WEBCONSOLE_HASH}" | chpasswd -e && \
  sshdir=/home/"${WEBCONSOLE_USER}"/.ssh && \
  mkdir -p "${sshdir}" && chmod 700 "${sshdir}" && chown "${WEBCONSOLE_USER}" "${sshdir}" && \

# Enable auto update of /etc/hosts by permanently
# looking for /webconsole/*.hosts
if [ -r /webconsole/ ]; then
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

exec "$@"