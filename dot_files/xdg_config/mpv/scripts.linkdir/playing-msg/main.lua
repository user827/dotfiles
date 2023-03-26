
local mp = require 'mp'
local mputils = require 'mp.utils'
local m = require 'libdir'
local options = require 'mp.options'
local o = {
  debug = false,
}

local function printdbg(msg)
  if o.debug then
    print(msg)
  end
end


local cwd
local timer

local function show_msg(verbose, t)
  local fn = m.strip_url(mp.get_property("path"))
  local cwdsub = string.sub(fn, 1, string.len(cwd))
  printdbg('cwdsub: ' .. cwdsub)
  if cwdsub ~= cwd then
    bn = fn
  else
    bn = string.sub(fn, string.len(cwd) + 2)
  end
  printdbg('bn: ' .. bn)

  local pos = mp.get_property_number('playlist-pos-1', 0)
  local count = mp.get_property_number('playlist-count', 0)

  if verbose then
    local size = mp.get_property_number('file-size', 0)
    local unit
    if size > 1024^3 then
      unit = 'GiB'
      size = size / 1024^3
    else
      unit = 'MiB'
      size = size / 1024^2
    end
    mp.osd_message(string.format('(%d/%d) %s\n %.2f %s\n %s', pos, count, bn, size, unit, cwd), t)
  else
    mp.osd_message(string.format('(%d/%d) %s', pos, count, bn), t)
  end
end

local function toggle_msg()
  if timer:is_enabled() then
    timer:kill()
    mp.osd_message("", 0)
  else
    timer:resume()
    show_msg(true, 10)
  end
end

options.read_options(o)
cwd = mputils.getcwd()
-- Create timer used for toggling, pause it immediately
timer = mp.add_periodic_timer(5, function() show_msg(true, 10) end)
timer:kill()
mp.register_event('file-loaded', function() show_msg(false,3) end)
mp.add_key_binding("I", "show-msg", function() toggle_msg() end)
-- printing info to osd causes jitter
mp.add_key_binding("K", "print-msg", function() print(mp.get_property_osd('vsync-jitter')) end)
