#!/bin/sh

# Make sure the directory for individual app logs exists
mkdir -p /var/log/shiny-server
chown shiny.shiny /var/log/shiny-server
print "Open up your browser to http://127.0.0.1:3838"
exec shiny-server >> /var/log/shiny-server.log 2>&1
