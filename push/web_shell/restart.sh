#!/bin/bash

pgrep -f config_web | xargs kill
cd ~/SimpleWeb/shell
sleep 0.1s
./run.sh