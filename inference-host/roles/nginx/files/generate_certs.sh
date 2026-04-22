#!/bin/bash

openssl req -x509 -newkey rsa:4096 -keyout /etc/nginx/nginx.key -out /etc/nginx/nginx.crt -sha256 -days 3650 -nodes -subj "/CN=${1}" -addext "subjectAltName = IP:${1}"
chgrp nginx /etc/nginx/nginx.key
chmod 640 /etc/nginx/nginx.key

