#!/bin/bash
set -e

if [ ! -f /var/lib/krb5kdc/principal ]; then
    kdb5_util create -s -P masterpassword
    kadmin.local -q "addprinc -pw devpassword developer@EXAMPLE.COM"
    kadmin.local -q "ktadd -k /etc/krb5kdc/developer.keytab developer@EXAMPLE.COM"
fi

krb5kdc
kadmind -nofork
