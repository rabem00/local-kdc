#!/bin/bash
# Quick cleanup script
# M. Rabelink 11/17/2024
#

check_running() {
    if docker ps --filter "name=kdc" --filter "status=running" --format '{{.Names}}' | grep -q '^kdc$'; then
        return 0
    else
        echo "The container 'kdc' is not running."
        return 1
    fi
}

#
# main Main MAIN
#
if [ -n "$SUDO_USER" ]; then
    USERNAME=$SUDO_USER
else
    USERNAME=$(whoami)
fi

check_running
if [ $? -eq 0 ]; then
    docker stop kdc
fi
docker rm kdc
rm /etc/krb5.conf
if [ -f /etc/krb5.conf.org ]; then
    echo "File /etc/krb5.conf.org exists."
    mv /etc/krb5.conf.org /etc/krb5.conf
    echo "Existing krb5.conf restored"
fi

if [ -f ./krb5cc_$USERNAME ]; then
    echo "Removing krb5 cache from home-dir"
    rm ./krb5cc_$USERNAME
fi

if [ -f ./developer.keytab ]; then
    echo "Removing developer.keytab"
    rm ./developer.keytab
fi

echo "Unset kerberos cache name"
unset KRB5CCNAME

echo "Note: KDC container image not removed."
echo "Run docker rmi local-kdc:latest to remove it."