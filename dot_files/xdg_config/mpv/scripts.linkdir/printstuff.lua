local function printstuff()
  local tp = mp.get_property("time-pos")
  print(tp)
  if tp ~= nil then
    mp.osd_message("time-pos: " .. tp)
  end
  -- tp = mp.get_property("chapter-list")
  -- print(tp)
  -- mp.set_property("chapter", "1")
end

mp.add_key_binding("Z", "print-stuff", printstuff)

-- mp.observe_property("time-pos", "number", on_time_change)

-- mp.observe_property("pause", "bool", on_pause_change)
