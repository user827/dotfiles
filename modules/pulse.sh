#!/bin/sh

install_module() {
  confpath=$modbase/pulse
  [ -d "$L_GEN_DIR/xdg_config/pulse" ] || mkdir "$L_GEN_DIR/xdg_config/pulse"
  sed "s,SED_THIS_DIR,$L_XDG_CONFIG/pulse,g" "$confpath/default.pa.gen" > "$L_GEN_DIR/xdg_config/pulse/default.pa"
  [ -f "$L_GEN_DIR/xdg_config"/pulse/local.pa ] || touch "$L_XDG_CONFIG"/pulse/local.pa
}
