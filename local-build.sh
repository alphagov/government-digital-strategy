#!/bin/bash
# we pass through $1 as if you pass through a parameter
# then it does the deploy steps as well (minifying)
ruby compiling/build.rb $1 --trace

