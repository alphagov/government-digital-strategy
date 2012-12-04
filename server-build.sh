#!/bin/bash

echo "Make sure the local LANG is set to UTF8"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

echo "Pulling from main repository"
git pull

echo "Bundling"
/usr/local/bin/bundle

/usr/local/bin/ruby compiling/get_assisted_digital.rb
/usr/local/bin/ruby compiling/build.rb $1 --trace

echo "Finished"
echo `date +%Y%m%d" at "%H:%M`
