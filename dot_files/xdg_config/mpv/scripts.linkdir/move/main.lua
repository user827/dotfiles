local mp = require 'mp'
local mpmsg = require 'mp.msg'
local mputils = require 'mp.utils'
local m = require("libdir")
local options = require 'mp.options'
local o = {
  debug = true,
  destbase = "mpv"
}

-- mylib end

local function printdbg(msg)
  if o.debug then
    print(msg)
  end
end

local gcwd

local function exists(path)
  local f = io.open(path, 'r')
  if f ~= nil then
    io.close(f)
    return true
  end
  return false
end

local function info(msg, timeout)
  mp.osd_message(msg, timeout)
  mpmsg.info(msg)
end

local function move(destbase, src)
  src = src:gsub('/$', '')
  local _, srcbase = mputils.split_path(src)
  printdbg('destbase: '.. destbase)
  printdbg('srcbase: '.. srcbase)
  local dst = mputils.join_path(destbase, srcbase)

  printdbg('src: '.. src)

  if exists(dst) then
    info("Destination already exists: " .. dst)
    return
  end
  local _, dstbn = mputils.split_path(destbase)
  local success, msg = os.rename(src, dst)
  if success == nil then
    info("Failed: " .. msg)
  else
    info("Moved " .. src .. ' to ' .. dstbn)
  end
end

local function doit(id, lvl)
  printdbg('init ' .. id)
  local dir = o.destbase .. id
  local err = mputils.subprocess({ args = { 'mkdir', '-p', '--', dir } })['status']
  if err ~= 0 then
    info("Cannot create " .. dir .. ": " .. err)
    return
  end
  move(dir, lvl)
end

local gsrc = 1
local is_active = false
local function set_active(active, lvl)
  if is_active == active then
    return
  end
  if active then
    local fn = mp.get_property("path")
    printdbg(fn)
    if not exists(m.strip_url(fn)) then
      info("Already (re)moved")
      return
    end

    mp.enable_key_bindings('repl-input', 'allow-hide-cursor+allow-vo-dragging')


    if lvl == 0 then
      gsrc = fn
    elseif lvl == -1 then
      gsrc = mputils.split_path(fn)
    else
      gsrc = m.get_subroot2(gcwd, fn, lvl)
    end

    info('Move (' .. gsrc .. '):', 30)
  else
    mp.disable_key_bindings('repl-input')
  end
  is_active = active
end

local function handle_char_input(c)
  if not is_active then
    return;
  end
  set_active(false, nil)
  doit(c, gsrc)
end

local function add_repl_bindings(bindings)
  local cfg = ''
  for i, binding in ipairs(bindings) do
    local key = binding[1]
    local fn = binding[2]
    local name = '__repl_binding_' .. i
    mp.add_key_binding(nil, name, fn, 'repeatable')
    cfg = cfg .. key .. ' script-binding ' .. mp.script_name .. '/' ..  name ..  '\n'
  end
  mp.commandv('define-section', 'repl-input', cfg, 'force')
end

local bindings = {
  { 'esc', function() info('Cancelled'); set_active(false) end },
}

local binding_name_map = {
  [' '] = 'SPACE',
  ['#'] = 'SHARP',
}

for b = (' '):byte(), ('~'):byte() do
  local c = string.char(b)
  local binding = binding_name_map[c] or c
  bindings[#bindings + 1] = {binding, function() handle_char_input(c) end}
end
add_repl_bindings(bindings)



gcwd = mputils.getcwd()
options.read_options(o)
m.debug = o.debug
--mp.add_key_binding("F12", "move-basepath", function () mp.osd_message('no destbase defined') end)
mp.add_key_binding("m", "move-basepath", function () set_active(true, 1) end)
mp.add_key_binding("n", "move-basepath-sub", function () set_active(true, 2) end)
mp.add_key_binding("b", "move-basename", function () set_active(true, 0) end)
mp.add_key_binding("B", "move-basedir", function () set_active(true, -1) end)
-- mp.add_key_binding("F10", "move-basepath-c", function () doit('c') end)
--mp.add_key_binding("F11", "move-basepath-b", function () doit('b') end)
--mp.add_key_binding("F12", "move-basepath-a", function () doit('a') end)
