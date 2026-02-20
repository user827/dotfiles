#!/bin/bash
set -eu

cd "$(dirname "$0")"

# Because we don't want to use foreach with --recursive at the top level because
# we don't know what the submodules of external repos can work with.
subtrees="vim"

case "${1-}" in
  checkout)
    for t in . $subtrees; do
      echo "checking out submodules in '$t'"
      git -C "$t" submodule foreach '
        BRANCH=$(git config -f "$toplevel/.gitmodules" submodule."$name".branch || git branch -r | grep origin/HEAD | cut -d\  -f5)
        git checkout "$BRANCH"
        '
    done
    ;;
  init|"")
    echo init
    #echo syncinc
    #git submodule sync --recursive
    echo initializing and updating
    git submodule update --init --recursive
    ;;
  update)
    for t in . $subtrees; do
      echo "updating '$t'"
      git -C "$t" submodule update --init --remote
      # Don't combine --recursive with --remote in order to avoid pulling a commit
      # that a subproject itself does not specify.
      git -C "$t" submodule foreach 'git submodule update --init --recursive'
    done
    ;;
  *)
    echo invalid command
    exit 1
esac

git status
for t in . $subtrees; do
  git -C "$t" status
  echo "Checking cleanable files in $t"
  out=$(git -C "$t" clean -dn)
  if [ -n "$out" ]; then
    echo "Do git -C $t clean -df to remove unnecessary files:"
    printf '%s\n' "$out"
  fi
done
