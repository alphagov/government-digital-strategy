#!/bin/bash

echo "Making the PDF"

ruby compiling/build-pdf.rb --folder $1
