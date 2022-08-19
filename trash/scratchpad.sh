#!/bin/bash

exec 1> >(logger -s -t $(basename $0)) 2>&1

echo "writing to stdout"
echo "writing to stderr" >&2

tail -f /var/log/system.log