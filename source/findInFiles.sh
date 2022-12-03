#!/bin/sh
grep --color=always --include=\*.pas -rnw . -e $1
