#!/bin/bash
ruby compiling/get_content.rb
ruby compiling/build.rb $1 --trace

