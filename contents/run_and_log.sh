#!/bin/sh

# A shell wrapper to both run a command and log the command and its results in results/log.log.

CMD=$@
echo Running,"$CMD" >> results/log.log
sh -c "$CMD" >> results/log.log 2>&1
