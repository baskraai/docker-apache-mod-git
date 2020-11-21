#!/bin/bash
set -e

source helpfunctions.sh

if [ "${SSH_KEY_MOUNT}" != "" ]; then
	echo_info "Option specified that ssh keys are mounted"
	cp -r "$SSH_KEY_MOUNT" ~/.ssh
	if [ ! $? ]; then
		echo_failed "Could not copy keys, does the SSH KEY mount work correctly?"
		exit 1
	fi
        chmod 700 ~/.ssh/id*
	echo_ok "GIT SSH Keys succesfully set"
elif [ "${SSH_PRIVKEY}" == "" ]; then
	echo_failed "SSH_PRIVKEY not specified."
	exit 1
elif [ "${SSH_PUBKEY}" == "" ] ; then
	echo_failed "SSH_PUBKEY not specified."
	exit 1
else
	echo_info "Settings the Git SSH Keys"
	mkdir -p ~/.ssh
	echo "$SSH_PUBKEY" > ~/.ssh/id_ecdsa.pub
	echo "$SSH_PRIVKEY" > ~/.ssh/id_ecdsa
	chmod 700 ~/.ssh/id_ecdsa*
	echo_ok "GIT SSH Keys succesfully set"
fi

echo_info "Settings the hostname of the apache2 instance"
echo "ServerName $HOSTNAME" > /etc/apache2/conf-available/fqdn.conf
a2enconf fqdn > /dev/null 2>&1
echo_ok "Hostname of the apache2 instance succesfully set to $HOSTNAME"

if [ "${CONFIG_REPO}" == "" ]; then
	echo_failed "CONFIG_REPO not defined"
	exit 1
else
	echo_info "Cloning the config from git"
	cd ~
	GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone "$CONFIG_REPO" config
	CONFIG_MOUNT="$(pwd)/config"
	echo_ok "Cloning config succesful"
fi

if [ "${CERT_REPO}" == "" ]; then
	echo_info "CERT_REPO not defined, not importing certificates"
else
	echo_info "Cloning the certs from git"
	cd ~
	GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone "$CERT_REPO" certs
	rsync -aq --copy-links certs/live/* /etc/cert/
	if [ ! $? ]; then
		echo_failed "Could not copy <repo>/live directory, does it exist?"
		echo_info "How does the <repo> dir looks:"
		ls -lah certs
		exit 1
	fi
	echo_ok "Cloning certs and copy to /etc/certs succesful"
fi

cd "$CONFIG_MOUNT"
echo_info "Copying the sites config"
rsync -aq sites/* /etc/apache2/sites-enabled/

echo_info "Checking the config"
/usr/sbin/apachectl configtest
if [ ! $? ]; then
	echo_failed "Apache2 config test failed."
	tail /var/log/apache2/*.log
	exit 1
fi

echo_info "Starting the apache2 deamon"
/usr/sbin/apachectl start

if [ ! $? ]; then
	echo_failed "apache2 deamon failed"
	tail /var/log/apache2/*.log
	exit 1
fi

echo_info "Print logs to stdout"
exec tail -fq /var/log/apache2/*.log
