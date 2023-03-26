-- load with --script

local mp = require 'mp'
local options = require 'mp.options'
local o = {
  pausefile = "",
  initstart = 0, -- the chapter to start from
  initpause = 0,
  loopstart = 1, -- read the chater to start from after the last chapter defined in pausefile on this line
  debug = false,
  skipchange = 20,
  pauselast = false
}


local function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

local function printdbg(msg)
  if o.debug then
    print(msg)
  end
end

local on_chapter_change
local playme

-- todo slow down first without comporomising stoppping accuracy eg:
-- seconds = 0
-- timer = mp.add_periodic_timer(1, function()
--    print("called every second")
--    # stop it after 10 seconds
--    seconds = seconds + 1
--    if seconds >= 10 then
--        timer:kill()
--    end
-- end)
--
--
local stopch_waittime
local stopch_getstop
local stopch_eof
local stopch_next
local stopch_set

local stopch = nil
local timer = nil

local function stopch_readfile_init()
  local idx = 1
  local timestamps = {}

  local f = io.open(o.pausefile, 'r')
  local contents = f:read("*all")
  f:close()

  local t = split(contents, "\n")
  local s
  local k
  local v
  for k,v in pairs(t) do
    -- print("k " .. k .. " v " .. v)
    s = split(v, " ")
    s[1] = tonumber(s[1])
    table.insert(timestamps, s)
  end

  stopch_waittime = function ()
    local t = timestamps[idx][2]
    if t == "r" then
      if o.debug then
        return math.random(5)
      else
        return math.random(20 * 60)
      end
    else
      return tonumber(t)
    end
  end

  stopch_getstop = function ()
    return timestamps[idx][1]
  end

  stopch_eof = function ()
    return timestamps[idx] == nil
  end

  stopch_next = function ()
    idx = idx + 1
  end

  stopch_set = function (what)
    idx = what
  end
end

local function stopch_ch_init()
  local numch = 0
  -- printdbg("numch " .. numch)
  local idx = o.loopstart
  mp.add_hook('on_preloaded', 60, function() numch = mp.get_property_number("chapter-list/count") end)

  stopch_waittime = function ()
    if o.debug then
      return math.random(5)
    else
      return math.random(20 * 60)
    end
  end

  stopch_getstop = function ()
    return idx
  end

  stopch_eof = function ()
    return idx >= numch
  end

  stopch_next = function ()
    idx = idx + 1
    if o.skipchange == 0 then
      return
    end
    while idx < numch - 1 do
      if math.random(o.skipchange) >= 10 then
        idx = idx + 1
      else
        break
      end
    end
  end

  stopch_set = function (what)
    idx = what
  end
end

local function loop()
  printdbg("looping")
  stopch_set(o.loopstart)
  local initch = o.loopstart > 0 and stopch_getstop() or o.initstart
  stopch_next()
  printdbg("initch " .. initch)
  mp.set_property("chapter", initch)
end


playme =  function()
  printdbg("startme")
  if stopch_eof() and o.pauselast then loop() end
  stopch = stopch_getstop()
  printdbg("stopch " .. stopch)
  mp.set_property("pause", "no")
end

on_chapter_change = function (name, ch)
  -- using options/end caues the playback to stop which then causes the restarting
  -- judders
  -- local tc = mp.get_property("options/end")
  -- mp.osd_message(tc)
  if stopch ~= nil and ch >= stopch then
    mp.set_property("pause", "yes")
    printdbg("on_chapter_change")
    stopch_set(ch)
    local untilstart = stopch_waittime()
    stopch_next()
    printdbg("untilstart " .. untilstart)

    if stopch_eof() and not o.pauselast then loop() end

    if timer == nil then
      timer = mp.add_timeout(untilstart, playme)
    else
      timer:kill() -- user might have unpaused before the timer triggered
      timer.timeout = untilstart
      timer:resume()
    end
  end
  printdbg("chapter " .. ch)
end

local function on_file_loaded()
  -- mp.commandv("seek", o.initstart, "absolute")
  if 0 ~= o.initstart then
    -- todo does not work with hook?
    -- mp.set_property("chapter", o.initstart)
    mp.set_property("options/start", "#"..(o.initstart + 1))
  end
  mp.observe_property("chapter", "number", on_chapter_change)
  if o.initpause > 0 then
    timer = mp.add_timeout(o.initpause, playme)
  else
    playme()
  end
end



options.read_options(o)

math.randomseed(os.time())

if o.initpause > 0 then
  mp.set_property("pause", "yes")
end

if o.pausefile == "" then
  stopch_ch_init()
else
  stopch_readfile_init()
end

-- mp.register_event('file-loaded', on_file_loaded)
mp.add_hook('on_preloaded', 50, on_file_loaded)
