#!/bin/bash
set -eu

# shellcheck source=install.sh
. "$L_LIB_PATH/install.sh"

get_installpath() {
  local conffile="$1" ans
  case "$conffile" in
    "$myroot"/home/*)
      installpath=$L_HOME/.${conffile#"$myroot/home/"}
      ;;
    "$myroot"/home_nodot/*)
      installpath=$L_HOME/${conffile#"$myroot/home_nodot/"}
      ;;
    "$myroot"/xdg_config/*)
      installpath=$L_XDG_CONFIG/${conffile#"$myroot/xdg_config/"}
      if ! [ -d "$L_XDG_CONFIG" ]; then
        echo "creating $L_XDG_CONFIG, press key to continue"
        [ -n "${BATCH:-}" ] || read -r ans
        mkdir -p -- "$L_XDG_CONFIG"
      fi
      ;;
    "$myroot"/bin/*)
      installpath=$L_USER_BINARIES/${conffile#"$myroot/bin/"}
      ;;
    "$myroot"/xdg_data/*)
      installpath=$L_XDG_DATA/${conffile#"$myroot/xdg_data/"}
      if ! [ -d "$L_XDG_DATA" ]; then
        echo creating "$L_XDG_DATA, press key to continue"
        [ -n "${BATCH:-}" ] || read -r ans
        mkdir -p -- "$L_XDG_DATA"
      fi
      ;;
    *)
      echo "unknown path: $conffile" >&2
      exit 1
      ;;
  esac
  if [ "$islinkdir" = 1 ]; then
    installpath=${installpath%.linkdir}
  fi
}

OPT_FORCE=false
if [ "$1" = --force ]; then
  OPT_FORCE=true
  shift
fi

# NOTE this file is linked to multiple locations
myroot=$1
myroot=$(cd "$myroot" && pwd)



exec 3<&0
for dir in \
  "$myroot"/bin \
  "$myroot"/home \
  "$myroot"/home_nodot \
  "$myroot"/xdg_config \
  "$myroot"/xdg_data
do
  [ -d "$dir" ] || { log info "$dir does not exist"; continue; }

  #TODO only skip chmod of type f
  find "$dir" -mindepth 1 \( -type d -name '*.linkdir' -prune -print \) -o -print | while read -r conffile; do
    #TODO might need
    [ "${conffile##*/}" = .gitignore ] && continue
    islinkdir=0
    case "$conffile" in *.linkdir) islinkdir=1 ;; esac

    get_installpath "$conffile" <&3

    if [ -d "$conffile" ] && [ ! -h "$conffile" ] && [ "$islinkdir" = 0 ]; then
      if [ -h "$installpath" ]; then
	echo -n "Remove link: $installpath? [y/N]: "
        [ -n "${BATCH:-}" ] || read -r ans <&3
	[ "$ans" != y ] && echo skipping "$installpath" && continue
	rm "$installpath"
      fi
      [ -d "$installpath" ] || mkdir "$installpath"
    else
      installdir=${installpath%/*}
      [ -d "$installdir" ] || mkdir -p "$installdir" || { echo skipping "$installpath" && continue; }
      Lln "$conffile" "$installpath" <&3
    fi
  done

  basedir=${dir##*/}
  [ -f "$myroot/${basedir}"_perms.sh ] && sh "$myroot/${basedir}"_perms.sh "$L_HOME"
done
#TODO others too
exit 0
