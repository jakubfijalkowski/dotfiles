-- The old `exec-once` lines run once at startup; the Lua equivalent is to run
-- them from the `hyprland.start` event.

hl.on("hyprland.start", function()
  hl.exec_cmd("uwsm-app -- walker --gapplication-service")
  hl.exec_cmd("uwsm-app -- wpaperd")
  hl.exec_cmd("uwsm-app -- 1password --silent")
  hl.exec_cmd("uwsm-app -- piv-unlock unlock")
end)
