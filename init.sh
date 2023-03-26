#!/bin/bash
set -eu

cd "$(dirname "$0")"
export L_GIT_ROOT="$PWD"
export L_LIB_PATH="$L_GIT_ROOT"/lib

# Require full paths
export L_HOME="$HOME"
export L_XDG_CONFIG="${XDG_CONFIG_HOME:=$HOME/.config}"
export L_XDG_DATA="${XDG_DATA_HOME:-$HOME/.local/share}"
export L_GEN_DIR="$L_GIT_ROOT"/dots_gen
L_USER_BINARIES="$(systemd-path user-binaries)"
export L_USER_BINARIES
modbase="$L_GIT_ROOT"/modules


# shellcheck source=lib/install.sh
. "$L_LIB_PATH/install.sh"
OPT_FORCE=false
if [ "${1-}" = --force ]; then
  OPT_FORCE=true
fi


log notice "(Re)Initializing $(basename "$PWD") with:"
msg "HOME=$L_HOME"
msg "XDG_CONFIG_DIR=$L_XDG_CONFIG"
msg "XDG_DATA_DIR=$L_XDG_DATA"
read -rp"press key to continue" ans

msg "Linking dots"
for f in "$L_GIT_ROOT"/dots/*; do Lln "$f" "$L_HOME/.${f##*/}"; done
#for e in "$L_GIT_ROOT"/xdg_config/*; do Lln "$e" "$L_XDG_CONFIG/.${e##*/}"; done

sh "$L_LIB_PATH"/dot_files.sh "$@" "$L_GIT_ROOT"/dot_files

msg "Cleaning up previously generated files"
for dir in bin home home_nodot xdg_config xdg_data; do
  [ -d "$L_GEN_DIR"/"$dir" ] && rm -r --interactive=never -- "${L_GEN_DIR:?}"/"$dir"
  mkdir -p "$L_GEN_DIR"/"$dir"
done


msg "Installing modules"
run_modules "$modbase" install_module

debug=
case $- in
  *x* ) debug=true ;;
esac
#A way to handle overwrite policy with ln.
bash ${debug:+-x} "$L_LIB_PATH"/dot_files.sh "$@" "$L_GIT_ROOT"/dots_gen

echo
vim/init.sh "$@"
