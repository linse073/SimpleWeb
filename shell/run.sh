#!/bin/bash

basepath=$(cd `dirname $0`; cd ..; pwd)
cd $basepath

log_dir="log"
[ ! -d "$log_dir" ] && mkdir -p "$log_dir"

record_dir="record"
[ ! -d "$record_dir" ] && mkdir -p "$record_dir"

./skynet/skynet config/config