# docker-webconsole
A docker container running WeTTy (https://github.com/butlerx/wetty)
Defaults: user `wetty`, password `wetty`, shell `/bin/sh`
Defaults could be overridden with
```
docker run ... \
-e WEBCONSOLE_USER='your_user' \
-e WEBCONSOLE_USER='your_hashed_password' \
-e WEBCONSOLE_SHELL='your_shell' \
roul76/wetty:latest
```
To hash your password use `openssl`:
```
openssl passwd -1 'your_password'
```