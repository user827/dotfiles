#!/bin/sh

sh ./remove_submodule.sh $(git clean -nd)
git clean -nd
