FROM debian:bullseye

RUN apt-get update && apt-get install -y \
    krb5-kdc krb5-admin-server \
    && apt-get clean

COPY ./krb5.conf /etc/krb5.conf
COPY ./kdc.conf /etc/krb5kdc/kdc.conf
COPY ./init-kdc.sh /usr/local/bin/init-kdc.sh

RUN echo "*/admin@EXAMPLE.COM *" > /etc/krb5kdc/kadm5.acl
RUN chmod +x /usr/local/bin/init-kdc.sh

EXPOSE 88 749

CMD ["init-kdc.sh"]
