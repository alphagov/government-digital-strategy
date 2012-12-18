#!/bin/bash
echo "If you get any errors, you probably need to update your dependencies."
echo "Run: bundle && npm install"
echo "And then try again!"


./local-build.sh deploy


if [[ "$1" == "pdf" ]]; then
  ./pdf.sh built/digital/strategy
  ./pdf.sh built/digital/efficiency
  ./pdf.sh built/digital/research
  ./pdf.sh built/la-ida-review
  ./pdf.sh built/digital/assisted
fi


ruby compiling/deploy.rb



