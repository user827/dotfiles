-- Quake like console on top
-- Similar to:
--   http://git.sysphere.org/awesome-configs/tree/scratch/drop.lua

-- But uses a different implementation. The main difference is that we
-- are able to detect the Quake console from its name
-- (QuakeConsoleNeedsUniqueName by default).

-- Use:

-- local quake = require("quake")
-- local quakeconsole = {}
-- for s = 1, screen.count() do
--    quakeconsole[s] = quake({ terminal = config.terminal,
--                              height = 0.3,
--                              screen = s })
-- end

-- config.keys.global = awful.util.table.join(
--    config.keys.global,
--    awful.key({ modkey }, "`",
--           function () quakeconsole[mouse.screen]:toggle() end)

-- If you have a rule like "awful.client.setslave" for your terminals,
-- ensure you use an exception for
-- QuakeConsoleNeedsUniqueName. Otherwise, you may run into problems
-- with focus.

-- local setmetatable = setmetatable
local string = string
local awful  = require("awful")
local join  = awful.util.table.join
local gears = require("gears")
local capi   = { mouse = mouse,
                 screen = screen,
                 client = client,
                 timer = gears.timer }

-- I use a namespace for my modules...
-- module("myrc.quake")

local QuakeConsole = {}

function QuakeConsole:set_visibility(visible)
  local c = self.client
   if visible then
      c:tags({capi.mouse.screen.selected_tag})
      c.hidden = false
      c:raise()
      capi.client.focus = c
   else
      c:tags({})
      c.hidden = true
   end
end

 function QuakeConsole:start_client()
   -- Sticky and on top
   -- c.ontop = true
   -- c.above = true
   -- wouldn't know that to do if accidentally
   -- minimized
   -- c.skip_taskbar = true
   -- cannot get focus after closing another window with this...
   -- c.sticky = false

   -- This is not a normal window, don't apply any specific keyboard stuff
   --   BUT me wants to be free!
   -- c:buttons({})
   -- c:keys({})

   awful.spawn.single_instance(
     join(self.terminal, {self.argname, self.name}, self.postargs),
     {
       floating = true,
       callback = function(c)
         self.client = c
         self:set_visibility(true)
       end,
     },
     function(c)
       return c.instance == self.name
     end
  )
end


function QuakeConsole:isQuake(c)
  return c.instance == self.name
end

-- Create a console
function QuakeConsole:new(config)
   -- The "console" object is just its configuration.

   -- The application to be invoked is:
   --   config.terminal .. " " .. string.format(config.argname, config.name)
   config.terminal = config.terminal or { "xterm" } -- application to spawn
   config.name     = config.name     or "QuakeConsoleNeedsUniqueName" -- window name
   config.argname  = config.argname  or "-name"     -- how to specify window name
   config.postargs = config.postargs  or {}            -- args after argname

   -- If width or height <= 1 this is a proportion of the workspace
   config.height   = config.height   or 0.25           -- height
   config.width    = config.width    or 1              -- width
   config.vert     = config.vert     or "top"          -- top, bottom or center
   config.horiz    = config.horiz    or "center"       -- left, right or center

   config.screen   = config.screen or capi.mouse.screen
   config.visible  = config.visible or false -- Initially, not visible

   local console = setmetatable(config, { __index = QuakeConsole })
   capi.client.connect_signal("manage",
                          function(c)
                             if c.instance == console.name then
                                console.client = c
                             end
                          end)
   capi.client.connect_signal("unmanage",
                          function(c)
                             if c.instance == console.name then
                               console.client = nil
                             end
                          end)

     if console.visible then
       console:start_client()
     end
   return console
end

-- Toggle the console
function QuakeConsole:toggle()
   if not self.client then
     self:start_client()
     return
   end

   if self.client.first_tag ~= capi.mouse.screen.selected_tag then
     self:set_visibility(true)
   else
     self:set_visibility(self.hidden)
   end
 end

setmetatable(QuakeConsole, { __call = function(_, ...) return QuakeConsole:new(...) end })
return QuakeConsole
