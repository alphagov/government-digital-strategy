#!/bin/bash

./local-build.sh

echo "Making the PDF"

ruby compiling/build-pdf.rb --folder $1
