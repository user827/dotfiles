#!/bin/sh
set -eu

sh ./remove_submodule.sh $(git clean -nd)
git clean -nd
