#!/bin/bash
set -eu

cd "$(dirname "$0")"

verify=--verify-signatures
if [ "${1-}" = --force ]; then
  verify=
  shift
fi
case "${1-}" in
  checkout)
    echo "checking out submodules"
    git submodule foreach '
      BRANCH=$(git config -f "$toplevel/.gitmodules" submodule."$name".branch || git branch -r | grep origin/HEAD | cut -d\  -f5)
      git checkout "$BRANCH"
      '
    ;;
  init|"")
    echo initializing and updating
    git submodule update --init --recursive
    ;;
  update)
    echo "updating"
    git submodule update --init --remote
    # Don't combine --recursive with --remote in order to avoid pulling a commit
    # that a subproject itself does not specify.
    git submodule foreach 'git submodule update --init --recursive'
    ;;
  *)
    echo invalid command
    exit 1
esac

git status
echo "Checking cleanable files"
out=$(git clean -dn)
if [ -n "$out" ]; then
  echo "Do git clean -df to remove unnecessary files:"
  printf '%s\n' "$out"
fi
