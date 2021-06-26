#!/bin/sh
if ! whoami &> /dev/null; then
  if [ -w /etc/passwd ]; then
    sed -i "s/imas:x:1000:0:/imas:x:`id -u`:0:/" /etc/passwd
  fi
fi
exec "$@"