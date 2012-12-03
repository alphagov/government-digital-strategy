#!/bin/bash
ruby compiling/get_assisted_digital.rb
ruby compiling/build.rb $1 --trace

