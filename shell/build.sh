#!/bin/bash

basepath=$(cd `dirname $0`; cd ..; pwd)
platform=$(uname)

function build() {
    echo "====================="
    echo "start build skyent..."
    cd $basepath/skynet
    if [[ "$platform" == "Darwin" ]]; then
        make macosx
    else
        make linux
    fi

    cd $basepath
    lib_dir="lib"
    [ ! -d "$lib_dir" ] && mkdir -p "$lib_dir"

    echo "====================="
    echo "clean..."
    cd $basepath
    find . -name "*.o"  | xargs rm -f

    echo "finish"
}

function clean() {
	echo "====================="
	echo "start clean skyent..."
	cd $basepath/skynet
	make clean

	echo "====================="
	echo "start clean lualib..."
    cd $basepath
    rm -f lib/*.so
    find . -name "*.dSYM"  | xargs rm -f -r
    find . -name "*.o"  | xargs rm -f

    echo "finish"
}

if [[ "$1" == "" ]]; then
	build
elif [[ "$1" == "clean" ]]; then
	clean
fi