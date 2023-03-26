local mp = require 'mp'
local mputils = require 'mp.utils'
local options = require 'mp.options'
local o = {
  debug = true,
  maxentries = 5000,
  rmlist = ""
}

local function printdbg(msg)
  if o.debug then
    print(msg)
  end
end

local function create_playlist()
  local tmp = os.tmpname()
  local file = io.open(tmp, 'w')
  local pl = mp.get_property_native("playlist", {})
  local found = false

  for i = 1, o.maxentries do
    local pl_e = pl[i]
    if pl_e == nil then
      break
    else
      found = true
      file:write(pl_e.filename, "\n")
    end
  end
  file:close()
  if found then
    return tmp
  else
    return nil
  end
end

local function fork_mpv(pos)
  printdbg('here')
  local list = create_playlist()
  if list == nil then
    mp.osd_message("no more entries")
    return
  end
  pos = mp.get_property_number("playlist-pos", 0) + pos
  local t = {
    args = { 'mpv','--really-quiet', '--no-input-terminal', '--playlist', list, '--playlist-start', pos, '--script-opts=fork-rmlist=' .. list },
    -- args = { 'sh', '-c', 'mpv --really-quiet --no-input-terminal --playlist=' .. list .. ' --playlist-start=2 --script-opts=fork-rmlist=' .. list ..' 2>&1 | logger' },
    --args = { 'sh','-c', 'trap "logger hup" HUP; sleep 1; logger hello' },
    -- args = { 'sh', '-c', 'mpv --no-input-terminal --playlist ' .. list ..' 2>&1 | logger' },
    cancellable = false
  }
  printdbg('starting')
  mputils.subprocess_detached(t)
  mp.osd_message("forked")
  -- os.remove(list)
end

options.read_options(o)
if o.rmlist ~= '' then
  printdbg('deleting ' .. o.rmlist)
  os.remove(o.rmlist)
end
mp.add_key_binding("N", "fork-next", function() fork_mpv(1) end)
mp.add_key_binding("F", "fork-current", function() fork_mpv(0) end)
