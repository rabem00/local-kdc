# LOCAL KDC
Create a local KDC container image for development purpose only!

## setup.sh
This will setup the environment (only tested on MacOS), but with minimal effort should also be usable on Linux. 

The setup.sh script needs docker installed and running. 
For instance on MacOS: 
```bash
brew install --cask docker && brew install bash-completion docker-completion docker-compose-completion
```

Note: the script will also authenticate with kinit, so if everything goes well you're authenticated as developer@EXAMPLE.COM with the developer.keytab in this directory. The kerberos cache file is also created in this directory. If an existing /etc/krb5.conf is present it will be copied to /etc/krb5.conf.org.

## cleanup.sh
The script will cleanup the environment. It stop and removes the kdc container. It removes (and restores /etc/krb5.conf if it was present during setup.sh). It unset the kerberos cache file.

## Do not run!
The init-kdc.sh is used by the container and should not be run from the command-line.

## Example test
Test using klist:
```bash
local-kdc % klist -kte developer.keytab
Keytab name: FILE:developer.keytab
KVNO Timestamp           Principal
---- ------------------- ------------------------------------------------------
   2 17-11-2024 14:22:40 developer@EXAMPLE.COM (aes256-cts-hmac-sha1-96)
   2 17-11-2024 14:22:40 developer@EXAMPLE.COM (aes128-cts-hmac-sha1-96)

local-kdc % klist
Ticket cache: KCM:0
Default principal: developer@EXAMPLE.COM

Valid starting       Expires              Service principal
17-11-2024 14:22:50  18-11-2024 00:22:50  krbtgt/EXAMPLE.COM@EXAMPLE.COM
	renew until 18-11-2024 14:22:50
local-kdc %
```
or test example using curl command. In this case with a FastAPI running that is using gssapi middleware:
```bash
curl --negotiate -u : http://localhost:8000/
```