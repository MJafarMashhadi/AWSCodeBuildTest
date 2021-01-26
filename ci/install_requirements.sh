#!/bin/bash

# quick and dirty, no getopts, no nothing.
if [ $# -lt 1 ]; then
  echo Target must be provided as an argument
fi

TARGET=$1
python -m pip install --no-cache -r requirements/$TARGET.txt
