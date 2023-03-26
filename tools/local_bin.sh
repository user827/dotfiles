#!/bin/sh
set -eu

# Install binaries to secure location where the user has no permission
# to change them for added security.
# TODO not only bins but others in home too like libs.

install_bin() {
  local "bin=$1" binname="$(basename "$1")"
  sudo rm -f "$SECBIN/$binname"
  sudo install -Cm 755 "$bin" "$SECBIN/"
}

update_changed() {
  cd "$(dirname "$0")"
  for changed in $(git diff --name-only HEAD'@{1}' bin); do
    [ -f "$changed" ] || { echo "doesn't exist: $changed" >&2; continue; }
    if [ -f "$SECHOME/$changed" ] && { [ -L "$SECHOME/$changed" ] || [ "$changed" -nt "$SECHOME/$changed" ]; }; then
      echo "update $SECHOME/$changed?"
      read -r ans
      [ "$ans" = y ] || continue
      echo updating
      install_bin "$changed"
    else
      echo skip "$changed"
    fi
  done
  cd - > /dev/null
}


do_up=0
USERHOME=$HOME
while [ $# -gt 0 ]; do
  case "$1" in
    -u)
      do_up=1
      ;;
    --home)
      USERHOME=$2
      shift
      ;;
    *)
      break
      ;;
  esac
  shift
done

if ! [ -d "$USERHOME" ]; then
  echo not a dir "$USERHOME" >&2
  exit 1
fi

#WITHOUT /bin
SECHOME=/opt$USERHOME
SECBIN=$SECHOME/bin



#TODO set alt home
if [ "$do_up" = 1 ]; then
  update_changed
else
  for bin; do
    install_bin "$bin"
  done
fi
