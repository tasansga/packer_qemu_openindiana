#!/bin/bash
set -xeuo pipefail

IFS=$'\n\t'

echo "${USERNAME} 127.0.0.1:/export/home/${USERNAME}" >> /etc/auto_home

svcadm disable \
  svc:/network/rpc/bind:default \
  svc:/network/rpc/gss:default \
  svc:/network/rpc/smserver:default \
  svc:/network/smtp:sendmail


su "${USERNAME}" <<EOF
set -e
mkdir -p /export/home/${USERNAME}/.ssh
chmod 0700 /export/home/${USERNAME}/.ssh
cat /tmp/id_rsa.pub > /export/home/${USERNAME}/.ssh/authorized_keys
rm -f /tmp/id_rsa.pub
chmod 644 /export/home/${USERNAME}/.ssh/authorized_keys
EOF

cat << EOF > /etc/ssh/sshd_config
Protocol 2
Port 22
ListenAddress ::
GatewayPorts no
PrintMotd no
KeepAlive yes
SyslogFacility auth
LogLevel info
StrictModes yes
PermitRootLogin no
MaxAuthTries 5
AuthorizedKeysFile .ssh/authorized_keys
PasswordAuthentication no
ChallengeResponseAuthentication no
X11Forwarding no
ClientAliveInterval 20
AcceptEnv LANG LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES
AcceptEnv LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT
AcceptEnv LC_IDENTIFICATION LC_ALL LANGUAGE
AcceptEnv XMODIFIERS
Subsystem       sftp    internal-sftp
IgnoreRhosts yes
AllowUsers ${USERNAME}
EOF

pkg update --accept
