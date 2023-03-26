#!/bin/sh
set -eu

url=$1
name=${1%.git}
name=${name##*/}
git submodule add --name "$name" "$url" data/"$name"
