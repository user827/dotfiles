-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

local quake = require("myrc.quake")
local revelation = require("revelation")
-- local countdown = require("mywidgets.countdown")
local volume = require("awesome-wm-widgets.volume-widget.volume")


-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = tostring(err) })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
local function inspect(t)
  for k,_ in pairs(t) do
    print(k)
  end
end
-- local myconfdir = gears.filesystem.get_configuration_dir()
local myhome = os.getenv("HOME")

-- local base02 = '#c8d1db'
local base0B = '#22863a'
-- Themes define colours, icons, font and wallpapers.
beautiful.init(awful.util.get_themes_dir() .. "zenburn/theme.lua")
beautiful.titlebar_bg_focus  = nil
beautiful.titlebar_bg_normal = nil
-- beautiful.init(awful.util.get_themes_dir() .. "xresources/theme.lua")
-- beautiful.bg_focus      = base02
-- beautiful.fg_focus      = beautiful.fg_normal
-- beautiful.fg_urgent     = beautiful.fg_normal
-- beautiful.fg_minimize   = beautiful.fg_normal


-- after beautiful init:
local volume_widget = volume({
  type = 'arc',
  tog_volume_cmd = 'pactl set-sink-mute @DEFAULT_SINK@ toggle',
  inc_volume_cmd = 'pactl set-sink-volume @DEFAULT_SINK@ +5%',
  dec_volume_cmd = 'pactl set-sink-volume @DEFAULT_SINK@ -5%',
})

revelation.init()



local mywp = myhome .. "/Desktop/wallpaper.jpg"
if awful.util.file_readable(mywp) then
  beautiful.wallpaper = mywp
end


-- This is used later as the default terminal and editor to run.
local terminal = "alacritty"
local display = os.getenv("DISPLAY")
local terminal_args_quake = {'-o', 'no-live-config-reload=false', '-e', 'tmux',  '-L', 'awesome_' .. display, 'new-session', '-s', 'awe', '-A'}
local editor = os.getenv("EDITOR") or "nano"
local editor_cmd = terminal .. " -e " .. editor

local quakeconsole = {}
awful.screen.connect_for_each_screen(function(s)
  quakeconsole[s] = quake({ terminal = { terminal },
                            postargs = terminal_args_quake,
                            height = 0.8,
                            width = 0.4,
                            argname = '--class',
                            horiz = "center",
                            visible = false,
                            screen = s })
end)

local mytrans = {}
mytrans.original_opacity = setmetatable({}, {__mode = "k"})
mytrans.opacity = setmetatable({}, {__mode = "k"})
mytrans.is_managed = setmetatable({}, {__mode = "k"})
function mytrans.toggle(c, opacity)
    mytrans.is_managed[c] = true
    if mytrans.opacity[c] == opacity then
      mytrans.opacity[c] = nil
      c.opacity = mytrans.original_opacity[c]
    else
      mytrans.opacity[c] = opacity
      if mytrans.original_opacity[c] == nil then
	mytrans.original_opacity[c] = c.opacity
      end
      c.opacity = opacity
    end
end

client.connect_signal("focus", function(c)
  if quakeconsole[mouse.screen]:isQuake(c) then
    c.border_color = base0B
  else
    c.border_color = beautiful.border_focus
  end

  if mytrans.is_managed[c] then
    if mytrans.opacity[c] == nil then
      c.opacity = 1
    else
      c.opacity = mytrans.opacity[c]
    end
  end
end)
client.connect_signal("unfocus", function(c)
  if not quakeconsole[mouse.screen]:isQuake(c) then
    if mytrans.opacity[c] == 1.0 then
      c.border_color = base0B
    else
      c.border_color = beautiful.border_normal
    end
  end
  if c.opacity == 1 then -- TODO does not detect if explicitly set?
    mytrans.is_managed[c] = true
  end
  if mytrans.is_managed[c] and mytrans.opacity[c] ~= 1.0 then
    c.opacity = 0.8
  end
end)

-- Startx errors
local servicebox = {}
function servicebox.failed(count)
  if count ~= 0 then
    servicebox.widget:set_markup('<span color="red" font_weight="bold"> S'.. count .. ' </span>')
  else
    servicebox.widget:set_markup('<span color="green"> ok </span>')
  end
  servicebox.last_failed_c = count
end

function servicebox.update_failed()
  awful.spawn.easy_async({'systemctl', '--user', 'show', '-p', 'NFailedUnits'}, function(count, _, _, exit_code)
    -- e.g. when systemd updates and reexecutes
    if exit_code ~= 0 then
      return
    end

    count = tonumber(count:match(".+=(%d+)"))
    if servicebox.last_failed_c ~= nil and count > servicebox.last_failed_c then
      if servicebox.last_notify == nil then
	local run = function(notification)
	  notification.die(naughty.notificationClosedReason.dismissedByUser)
	  servicebox.last_notify = nil
	end
	servicebox.last_notify = naughty.notify({text       = "Service failed!"
				       , preset     = naughty.config.presets.critical
				       , run = run
	})
      end
    end
    servicebox.failed(count)
  end)
end

servicebox.widget = wibox.widget.textbox()
gears.timer({
  autostart = true,
  call_now = true,
  callback = servicebox.update_failed,
  timeout = 5 })


local errorbox = {}
errorbox.count = 0
errorbox.widget = wibox.widget.textbox()
errorbox.widget.visible = false
function errorbox.reset(_, _, _, button)
  if button == 1 then
    awful.spawn({'alacritty', '-e', 'sudo', '-A', 'journalctl', '-b', '-r', '-p3'}, false)
  end
  errorbox.widget.visible = false
  errorbox.count = 0
end
errorbox.widget:connect_signal('button::press', errorbox.reset)
function errorbox:failed()
  errorbox.count = 1 + errorbox.count
  errorbox.widget.visible = true
  errorbox.widget:set_markup('<span color="red" font_weight="bold"> E'.. errorbox.count .. ' </span>')
  awful.spawn({'paplay', '-n', 'awesome', '--property=media.role=event', '--volume=40000', '/usr/share/sounds/freedesktop/stereo/message-new-instant.oga'}, false)
end



-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
local modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier,
    awful.layout.suit.corner.nw,
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
   { "hotkeys", function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
   { "manual", terminal .. " -e man awesome" },
   { "edit config", editor_cmd .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", function() awesome.quit() end },
}

local mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                    { "open terminal", terminal }
                                  }
                        })

local mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon,
                                     menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
local mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                    awful.button({ }, 1, function(t) t:view_only() end),
                    awful.button({ modkey }, 1, function(t)
                                              if client.focus then
                                                  client.focus:move_to_tag(t)
                                              end
                                          end),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, function(t)
                                              if client.focus then
                                                  client.focus:toggle_tag(t)
                                              end
                                          end),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(t.screen) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(t.screen) end)
                )

local tasklist_buttons = gears.table.join(
                     awful.button({ }, 1, function (c)
                                              if c == client.focus then
                                                  c.minimized = true
                                              else
                                                  c:emit_signal(
                                                      "request::activate",
                                                      "tasklist",
                                                      {raise = true}
                                                  )
                                              end
                                          end),
                     awful.button({ }, 3, function()
                                              awful.menu.client_list({ theme = { width = 250 } })
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                          end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then
            wallpaper = wallpaper(s)
        end
        gears.wallpaper.maximized(wallpaper, s, false)
        -- gears.wallpaper.centered(wallpaper, s, nil, 1)
        -- gears.wallpaper.fit(wallpaper, s)
    end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5", "6", "7", "8", "9" }, s, {
      awful.layout.suit.floating,
      awful.layout.suit.floating,
      awful.layout.suit.floating,
      awful.layout.suit.tile,
      awful.layout.suit.tile,
      awful.layout.suit.tile,
      awful.layout.suit.tile,
      awful.layout.suit.tile,
      awful.layout.suit.tile
    })

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                           awful.button({ }, 1, function () awful.layout.inc( 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(-1) end),
                           awful.button({ }, 4, function () awful.layout.inc( 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(-1) end)))
    -- Create a taglist widget
    s.mytaglist = awful.widget.taglist {
        screen  = s,
        filter  = awful.widget.taglist.filter.all,
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({ position = "top", screen = s })

    -- Add widgets to the wibox
    s.mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            mylauncher,
            s.mytaglist,
            -- countdown.checkbox,
            s.mypromptbox,
        },
        s.mytasklist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            -- countdown.widget,
            volume_widget,
            mykeyboardlayout,
            wibox.widget.systray(),
            servicebox.widget,
            errorbox.widget,
            mytextclock,
            s.mylayoutbox,
        },
    }
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local globalkeys = gears.table.join(
    awful.key({ modkey, 'Control',           }, "s",      hotkeys_popup.show_help,
              {description="show help", group="awesome"}),
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev,
              {description = "view previous", group = "tag"}),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext,
              {description = "view next", group = "tag"}),
    awful.key({ modkey, 'Shift',           }, "Escape", awful.tag.history.restore,
              {description = "go back", group = "tag"}),

    awful.key({ modkey,           }, "j",
        function ()
            awful.client.focus.byidx( 1)
        end,
        {description = "focus next by index", group = "client"}
    ),
    awful.key({ modkey,           }, "k",
        function ()
            awful.client.focus.byidx(-1)
        end,
        {description = "focus previous by index", group = "client"}
    ),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
              {description = "show main menu", group = "awesome"}),

    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end,
              {description = "swap with next client by index", group = "client"}),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end,
              {description = "swap with previous client by index", group = "client"}),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end,
              {description = "focus the next screen", group = "screen"}),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end,
              {description = "focus the previous screen", group = "screen"}),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto,
              {description = "jump to urgent client", group = "client"}),
    awful.key({ modkey,           }, "Tab",
        function ()
            awful.client.focus.history.previous()
            if client.focus then
                client.focus:raise()
            end
        end,
        {description = "go back", group = "client"}),

    -- Standard program
    awful.key({ modkey,           }, "Return", function () awful.spawn(terminal) end,
              {description = "open a terminal", group = "launcher"}),
    awful.key({ modkey, "Control" }, "r", awesome.restart,
              {description = "reload awesome", group = "awesome"}),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

    awful.key({ modkey,           }, "l",     function () awful.tag.incmwfact( 0.05)          end,
              {description = "increase master width factor", group = "layout"}),
    awful.key({ modkey,           }, "h",     function () awful.tag.incmwfact(-0.05)          end,
              {description = "decrease master width factor", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "h",     function () awful.tag.incnmaster( 1, nil, true) end,
              {description = "increase the number of master clients", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "l",     function () awful.tag.incnmaster(-1, nil, true) end,
              {description = "decrease the number of master clients", group = "layout"}),
    awful.key({ modkey, "Control" }, "h",     function () awful.tag.incncol( 1, nil, true)    end,
              {description = "increase the number of columns", group = "layout"}),
    awful.key({ modkey, "Control" }, "l",     function () awful.tag.incncol(-1, nil, true)    end,
              {description = "decrease the number of columns", group = "layout"}),
    awful.key({ "Control", "Shift" }, "space", function () awful.layout.inc( 1)                end,
              {description = "select next", group = "layout"}),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(-1)                end,
              {description = "select previous", group = "layout"}),

    awful.key({ modkey, "Control" }, "n",
              function ()
                  local c = awful.client.restore()
                  -- Focus restored client
                  if c then
                    c:emit_signal(
                        "request::activate", "key.unminimize", {raise = true}
                    )
                  end
              end,
              {description = "restore minimized", group = "client"}),

    -- Prompt
    awful.key({ modkey },            "r",     function () awful.screen.focused().mypromptbox:run() end,
              {description = "run prompt", group = "launcher"}),

    awful.key({ modkey }, "x",
              function ()
                  awful.prompt.run {
                    prompt       = "Run Lua code: ",
                    textbox      = awful.screen.focused().mypromptbox.widget,
                    exe_callback = awful.util.eval,
                    history_path = awful.util.get_cache_dir() .. "/history_eval"
                  }
              end,
              {description = "lua execute prompt", group = "awesome"}),
    -- Menubar
    awful.key({ modkey }, "p", function() menubar.show() end,
              {description = "show the menubar", group = "launcher"})
)

local clientkeys = gears.table.join(
    awful.key({ modkey,           }, "f",
        function (c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        {description = "toggle fullscreen", group = "client"}),
    awful.key({ modkey, "Shift"   }, "c",      function (c) c:kill()                         end,
              {description = "close", group = "client"}),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ,
              {description = "toggle floating", group = "client"}),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end,
              {description = "move to master", group = "client"}),
    awful.key({ modkey,           }, "o",      function (c) c:move_to_screen()               end,
              {description = "move to screen", group = "client"}),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end,
              {description = "toggle keep on top", group = "client"}),
    awful.key({ modkey,           }, "n",
        function (c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end ,
        {description = "minimize", group = "client"}),
    awful.key({ modkey,           }, "m",
        function (c)
            c.maximized = not c.maximized
            c:raise()
        end ,
        {description = "(un)maximize", group = "client"}),
    awful.key({ modkey, "Control" }, "m",
        function (c)
            c.maximized_vertical = not c.maximized_vertical
            c:raise()
        end ,
        {description = "(un)maximize vertically", group = "client"}),
    awful.key({ modkey, "Shift"   }, "m",
        function (c)
            c.maximized_horizontal = not c.maximized_horizontal
            c:raise()
        end ,
        {description = "(un)maximize horizontally", group = "client"})
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys,
        -- View tag only.
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = awful.screen.focused()
                        local tag = screen.tags[i]
                        if tag then
                           tag:view_only()
                        end
                  end,
                  {description = "view tag #"..i, group = "tag"}),
        -- Toggle tag display.
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = awful.screen.focused()
                      local tag = screen.tags[i]
                      if tag then
                         awful.tag.viewtoggle(tag)
                      end
                  end,
                  {description = "toggle tag #" .. i, group = "tag"}),
        -- Move client to tag.
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:move_to_tag(tag)
                          end
                     end
                  end,
                  {description = "move focused client to tag #"..i, group = "tag"}),
        -- Toggle tag on focused client.
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus then
                          local tag = client.focus.screen.tags[i]
                          if tag then
                              client.focus:toggle_tag(tag)
                          end
                      end
                  end,
                  {description = "toggle focused client on tag #" .. i, group = "tag"})
    )
end


-- {{{MYKEYS
-- modkey and ctrl+shift combinations are safe with terminal
-- ctrl+shift keys are safe from awesome
globalkeys = awful.util.table.join(globalkeys,
    awful.key({ modkey }, "space", function ()
      mykeyboardlayout.next_layout()
      naughty.notify({text = "Keyboard Layout", timeout = 2})
    end),
    awful.key({ "Control", "Shift" }, "l", function () awful.spawn({'xset', 's', 'activate' }, false) end),

    awful.key({ modkey }, "e", revelation),
    --use a keycode insterad of eg. `, so the binding works in all keyboard layouts
    awful.key({ modkey }, "#49", function ()
      quakeconsole[mouse.screen]:toggle() end),
    awful.key({ }, "#107", function ()
      awful.spawn({'screenshot'}, false) end),
    awful.key({ modkey }, "Escape", function ()
      quakeconsole[mouse.screen]:toggle() end)
    -- awful.key({ modkey, "Shift" }, "#49", function ()
      -- quakeconsole[mouse.screen]:donotwantme() end)
)

clientkeys = awful.util.table.join(clientkeys,
  awful.key({ modkey            }, "s",      function (c) mytrans.toggle(c, 1.00)           end),
  awful.key({ modkey,  "Shift"  }, "s",      function (c) mytrans.toggle(c, 0.95)            end)
)
-- }}}


local clientbuttons = gears.table.join(
    awful.button({ }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
    end),
    awful.button({ modkey }, 1, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.move(c)
    end),
    awful.button({ modkey }, 3, function (c)
        c:emit_signal("request::activate", "mouse_click", {raise = true})
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     raise = true,
                     keys = clientkeys,
                     buttons = clientbuttons,
                     screen = awful.screen.preferred,
                     placement = awful.placement.no_overlap+awful.placement.no_offscreen
     }
    },

    -- Floating clients.
    { rule_any = {
        instance = {
          "DTA",  -- Firefox addon DownThemAll.
          "copyq",  -- Includes session name in class.
          "pinentry",
        },
        class = {
          "Anki",
          "Arandr",
          "Blueman-manager",
          "Gpick",
          "Kruler",
          "MessageWin",  -- kalarm.
          "QEMU",
          "Steam",
          "Sxiv",
          "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
          "Wine",
          "Wpa_gui",
          "gimp",
          "mpv",
          "pinentry",
          "steam.exe",
          "veromix",
          "xtightvncviewer"},

        -- Note that the name property shown in xprop might be set slightly after creation of the client
        -- and the name shown there might not match defined rules here.
        name = {
          "Event Tester",  -- xev.
        },
        role = {
          "AlarmWindow",  -- Thunderbird's calendar.
          "ConfigManager",  -- Thunderbird's about:config.
          "pop-up",       -- e.g. Google Chrome's (detached) Developer Tools.
        }
      }, properties = { floating = true }},

    -- Add titlebars to normal clients and dialogs
    { rule_any = {type = { "normal", "dialog" } },
      properties = { titlebars_enabled = true }
    },

    -- Set Firefox to always map on the tag named "2" on screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { screen = 1, tag = "2" } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
      and not c.size_hints.user_position
      and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(
        awful.button({ }, 1, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            c:emit_signal("request::activate", "titlebar", {raise = true})
            awful.mouse.client.resize(c)
        end)
    )

    awful.titlebar(c) : setup {
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout  = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align  = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout  = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton (c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton   (c),
            awful.titlebar.widget.ontopbutton    (c),
            awful.titlebar.widget.closebutton    (c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)






naughty.config.notify_callback = function(args)
  local soundfile
  local volume
  if args.preset and args.preset.presetname == 'normal' then
    soundfile = '/usr/share/sounds/freedesktop/stereo/message.oga'
    volume=30000
  elseif args.preset and args.preset.presetname == 'critical' then
    soundfile = '/usr/share/sounds/freedesktop/stereo/message-new-instant.oga'
    volume=40000
  end
  local hints = args.freedesktop_hints
  if hints then
    -- for k,_ in pairs(hints) do
    --   print(k)
    -- end
    if hints['sound-file'] then
      soundfile = hints['sound-file']
    end
  end

  if soundfile then
    awful.spawn({'paplay', '-n', 'awesome', '--property=media.role=event', '--volume='..volume, soundfile}, false)
  end

  return args
end

naughty.config.defaults.position = "bottom_right"
naughty.config.defaults.opacity = 0.8

naughty.config.presets.low.presetname = 'low'
naughty.config.presets.normal.presetname = 'normal'
naughty.config.presets.critical.presetname = 'critical'
naughty.config.presets.critical.callback = function(_, _, _, _, title, _, _, _, _)
  if title == 'Critical event' then
    errorbox.failed()
  end
  return true
end
-- }}}


local rem_last_id = nil
local function show_reminders()
  awful.spawn.easy_async('rem -h', function(stdout, stderr, exit_reason, exit_code)
    if exit_code ~= 0 or stderr ~= '' then
      naughty.notify({ preset = naughty.config.presets.critical,
      title = "Reminders error: " .. exit_reason,
      text = stderr })
    end

    if stdout ~= '' then
      -- trim the last 2 newlines
      local text = stdout:sub(1,-3)
      -- skip the first header and the following empty line
      local i = string.find(text, "\n")
      text = text:sub(i+2,-1)
      rem_last_id = naughty.notify({
        preset = naughty.config.presets.low,
        timeout = 0,
        replaces_id = rem_last_id,
        title = "Reminders",
        text = text }).id
    end
  end)
end

gears.timer {
  timeout = 86400,
  autostart = true,
  call_now = true,
  callback = show_reminders,
}


-- no permission?
-- dbus.request_name('system', "org.awesomewm.MyAwful")

-- works:
-- dbus.add_match('system', "type='signal',interface='org.awesomewm.MyAwful',member='Notify'")
-- dbus.connect_signal("org.awesomewm.MyAwful", function (data)
--   print('hello')
--   -- works but this does not seem to be private
-- end)
-- see: /usr/share/awesome/lib/naughty/dbus.lua

-- vim:set fdm=marker:
