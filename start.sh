#!/bin/bash

/tmp/configure_socks_ports.sh
tor -f /etc/torrc &
cd /app && bundle exec puma -t 5:5
