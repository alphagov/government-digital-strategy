#!/bin/bash
# we had problems caused with encoding.
# these make sure the encoding is UTF8 which seems to fix it
echo "Make sure the local LANG is set to UTF8"
export LANG=en_US.UTF-8
export LC_ALL=en_US.UTF-8
export LANGUAGE=en_US.UTF-8

echo "Pulling from main repository"
git pull

echo "Bundling"
/usr/local/bin/bundle

echo "Running build script"
/usr/local/bin/ruby build.rb --trace

echo "Finished"
echo `date +%Y%m%d" at "%H:%M`
