local mp = require 'mp'
local mputils = require 'mp.utils'
local options = require 'mp.options'
local o = {
  debug = false,
  maxentries = 5000,
}

local cwd

local function printdbg(msg)
  if o.debug then
    print(msg)
  end
end

local function get_subroot(relative, pentry)
  local bn
  printdbg("pentry " .. pentry)
  pentry = string.gsub(pentry, "^[a-z]-://[0-9]-/(.*)", "%1")
  printdbg("pentry nourl: " .. pentry)
  repeat
    pentry, bn = mputils.split_path(pentry)
    printdbg("pentry now " .. pentry)
    if pentry ~= '.' then
      pentry = string.sub(pentry, 1, -2)
    end
    printdbg("pentry now " .. pentry)
  until pentry == '.' or pentry == relative
  printdbg("subroot " .. bn)
  return bn
end

local function doit(direction)
  local path = mp.get_property("path", "")
  local dir, filename = mputils.split_path(path)
  local pl = mp.get_property_native("playlist", {})
  local pl_current = mp.get_property_number("playlist-pos", 0) + 1

  local curroot = get_subroot(cwd, path)
  for i = 1, o.maxentries do
    local pl_e = pl[pl_current + i * direction]
    if pl_e == nil then
      printdbg("end of playlist")
      mp.osd_message("end of playlist")
      break
    end
    if curroot ~= get_subroot(cwd, pl_e.filename) then
      mp.set_property("playlist-pos", pl_current - 1 + i * direction)
      break
    end
  end
end

local function prev_dir()
  doit(-1)
end

local function next_dir()
  doit(1)
end


options.read_options(o)
cwd = mputils.getcwd()
-- mp.add_key_binding("F1", "prev-dir", prev_dir)
-- mp.add_key_binding("F2", "next-dir", next_dir)
mp.add_key_binding("ctrl+1", "prev-dir", prev_dir)
mp.add_key_binding("ctrl+2", "next-dir", next_dir)
