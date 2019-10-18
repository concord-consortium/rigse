#!/bin/bash

# this is a simple script to attach a console to the running app container
# it is useful for debugging the app. Another requirement for debugging is to enable
# stdin and tty. This is already done in docker-compose.yml
docker attach $(docker-compose ps -q app)
