#!/bin/sh

#
# Script designed to be run for development purposes only.
#

"${SUEXEC:-doas}" make XCLIPSYNC_VERSION=`make -V XCLIPSYNC_VERSION`+`git rev-parse HEAD`
