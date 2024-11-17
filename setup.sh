#!/bin/bash
# Quick start script
# M. Rabelink 11/17/2024
#

# The path to the krb5.conf file (typically /etc/krb5.conf)
KRB5_CONF="/etc/krb5.conf"

check_running() {
    if docker ps --filter "name=kdc" --filter "status=running" --format '{{.Names}}' | grep -q '^kdc$'; then
        return 0
    else
        # Not running!
        return 1
    fi
}

copy_keytab() {
    docker cp kdc:/etc/krb5kdc/developer.keytab .
    chown $USERNAME developer.keytab
    export KRB5CCNAME=./krb5cc_$USERNAME
}

auth_with_keytab() {
    kinit -kt ./developer.keytab developer@EXAMPLE.COM
    chown $USERNAME krb5cc_$USERNAME
}

create_krb5_conf() {
    # Define the KDC host and path to krb5.conf
    KDC_HOST=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' kdc)
    KRB5_CONF="/etc/krb5.conf"
    KRB5_CONF_ORG="${KRB5_CONF}.org"  # Backup file name with .org extension

    # Check if the krb5.conf file exists
    if [ -f "$KRB5_CONF" ]; then
        echo "The file $KRB5_CONF already exists. Creating a backup as $KRB5_CONF_ORG."
        cp "$KRB5_CONF" "$KRB5_CONF_ORG"  # Create backup with .org extension
    fi
    
    # Create the krb5.conf file using the here document
    cat > "$KRB5_CONF" <<EOL
[libdefaults]
    default_realm = EXAMPLE.COM
    dns_lookup_kdc = false
    dns_lookup_realm = false

[realms]
    EXAMPLE.COM = {
        kdc = localhost
        admin_server = localhost
    }

[domain_realm]
    .example.com = EXAMPLE.COM
    example.com = EXAMPLE.COM
EOL

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
    echo "The container 'kdc' is running."
    copy_keytab
    create_krb5_conf
    auth_with_keytab
else
    echo "The container 'kdc' is not running. Trying too start.."
    docker run -d --name kdc -p 88:88 -p 749:749 local-kdc
    sleep 10
    copy_keytab
    create_krb5_conf
    auth_with_keytab
fi
