#!/bin/sh
rm -rfv /tmp/.X*-lock /tmp/.X11-unix || echo "remove old vnc locks to be a reattachable container"

# Start XServer
vncserver :1 &

tail -f /dev/null
