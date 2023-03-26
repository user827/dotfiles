-- This script cycles between deinterlacing, pullup (inverse
-- telecine), and both filters off. It uses the "deinterlace" property
-- so that a hardware deinterlacer will be used if available.
--
-- It overrides the default deinterlace toggle keybinding "D"
-- (shift+d), so that rather than merely cycling the "deinterlace" property
-- between on and off, it adds a "pullup" step to the cycle.
--
-- It provides OSD feedback as to the actual state of the two filters
-- after each cycle step/keypress.
--
-- Note: if hardware decoding is enabled, pullup filter will likely
-- fail to insert.
--
-- TODO: It might make sense to use hardware assisted vdpaupp=pullup,
-- if available, but I don't have hardware to test it. Patch welcome.

local script_name = mp.get_script_name()
local pullup_label = string.format("%s-pullup", script_name)

local function pullup_on()
    for i,vf in pairs(mp.get_property_native('vf')) do
        if vf['label'] == pullup_label then
            return true
        end
    end
    return false
end

local function cycle_deinterlace_pullup_handler()
    if pullup_on() then
      -- if pullup is on remove it
      mp.command(string.format("vf del @%s:pullup", pullup_label))
      mp.osd_message("pullup: no")
    else
      mp.command(string.format("vf add @%s:pullup", pullup_label))
      if mp.get_property_bool("deinterlace") then
        mp.osd_message("pullup: yes (with deinterlace)")
      else
        mp.osd_message("pullup: yes")
      end
    end
end

mp.add_key_binding("D", "cycle-deinterlace-pullup", cycle_deinterlace_pullup_handler)
