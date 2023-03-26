local mputils = require 'mp.utils'
local m = {}

function m.printdbg(msg)
  if m.debug then
    print(msg)
  end
end

function m.get_subroot2(relative, pentry, lvl)
  local sub = m.get_subroot(relative, pentry)
  m.printdbg("get_subroot2: sub: " .. sub)
  if lvl == 2 then
    local c = mputils.join_path(relative, sub)
    m.printdbg("get_subroot2: c: " .. c)
    local s = m.get_subroot(c, pentry)
    m.printdbg("get_subroot2: s: " .. s)
    sub = mputils.join_path(sub, s)
    m.printdbg("get_subroot2: sub: " .. sub)
  end
  return sub
end


function m.get_subroot(relative, pentry)
  local bn
  m.printdbg("pentry " .. pentry)
  pentry = string.gsub(pentry, "^[a-z]-://[0-9]-/(.*)", "%1")
  m.printdbg("pentry nourl: " .. pentry)
  repeat
    pentry, bn = mputils.split_path(pentry)
    m.printdbg("pentry now " .. pentry)
    if pentry ~= '.' then
      pentry = string.sub(pentry, 1, -2)
    end
    m.printdbg("pentry now " .. pentry)
  until pentry == '.' or pentry == relative
  m.printdbg("subroot " .. bn)
  return bn
end

function m.strip_url(pentry)
  return string.gsub(pentry, "^[a-z]-://[0-9]-/(.*)", "%1")
end

return m
