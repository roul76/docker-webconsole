#!/bin/sh
set -o pipefail

# Allow traffic once a connection has been made
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

# Limit incoming traffic to port 3000
iptables -A INPUT -p tcp --dport "${WEBCONSOLE_PORT}" -j ACCEPT
iptables -A OUTPUT -p tcp --sport "${WEBCONSOLE_PORT}" -m state --state ESTABLISHED -j ACCEPT

# SYN flood protection
iptables -N SYN_FLOOD
iptables -A INPUT -p tcp --syn -j SYN_FLOOD
iptables -A SYN_FLOOD -m limit --limit 5/s --limit-burst 10 -j RETURN
iptables -A SYN_FLOOD -j DROP

# Limit outgoing network access to WEBCONSOLE_BRIDGE_SUBNET
[ "${WEBCONSOLE_BRIDGE_SUBNET}" != "" ] && \
  iptables -A OUTPUT -d "${WEBCONSOLE_BRIDGE_SUBNET}" -j ACCEPT

# Create login user
[ "${WEBCONSOLE_USER}" != "" -a "${WEBCONSOLE_HASH}" != "" -a "${WEBCONSOLE_SHELL}" != "" ] && \
  adduser -S -h /home/"${WEBCONSOLE_USER}" -s "${WEBCONSOLE_SHELL}" "${WEBCONSOLE_USER}" && \
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