#!/bin/sh

#Systemd files cannot be symlinked
install_module() {
  confpath=$modbase/systemd

  mkdir -p "$L_XDG_CONFIG/systemd/user/"

  cd "$confpath"
  for f in * user/* user/*/*; do
    if [ ! -f "$f" ] && [ ! -h "$f" ]; then
      continue
    fi
    case "$f" in
      *.sh)
        dst="$L_XDG_CONFIG/systemd/$f"
        Lln "$f" "$dst"
        ;;
      *.in)
        if [ -h "$f" ]; then
          error "assertion error: $f cannot be a link"
        fi
        local dst="$L_XDG_CONFIG/systemd/${f%.in}"
        local dstdir="${dst%/*}"
        [ -d "$dstdir" ] || mkdir -v "$dstdir"
        Ltmp
        local tmpdst=$_RET
        sed -e "s,@userhome@,$L_HOME,g" \
          -e "s,@startups@,$L_XDG_CONFIG/systemd,g" \
          "$f" > "$tmpdst"
        install_file "$tmpdst" "$dst"
        rm -- "$tmpdst"
	;;
      *)
        local dst="$L_XDG_CONFIG/systemd/$f"
        local dstdir="${dst%/*}"
        [ -d "$dstdir" ] || mkdir -v "$dstdir"
        install_file "$f" "$dst"
	;;
    esac
  done

  if [ -n "${XDG_RUNTIME_DIR:-}" ] || [ -n "${DBUS_SESSION_BUS_ADDRESS:-}" ]
  then
    systemctl --user daemon-reload
  else
    echo "skipping systemctl --user"
  fi
}
