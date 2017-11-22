# tls-gen
Create a Certificate Authority and sign certs with it

```
usage: tls-gen.sh -n HOST_NAME -c CA_NAME

If directory CA_NAME exists, cert will be signed by that CA
If directory CA_NAME does not exist, a new CA will be created and used

Keys and certs for hosts will be created under the directory of the CA that signs them.
```
