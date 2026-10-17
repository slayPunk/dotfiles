local mainMod = _G.mainMod or "SUPER"
local terminal = _G.terminal or "kitty"

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

hl.bind(mainMod .. " + SHIFT + Left", hl.dsp.window.resize({ x = -50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Right", hl.dsp.window.resize({ x = 50, y = 0, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Up", hl.dsp.window.resize({ x = 0, y = -50, relative = true }), { repeating = true })
hl.bind(mainMod .. " + SHIFT + Down", hl.dsp.window.resize({ x = 0, y = 50, relative = true }), { repeating = true })

hl.bind(mainMod .. " + CTRL + Left", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + CTRL + Right", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + CTRL + Up", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + CTRL + Down", hl.dsp.window.move({ direction = "d" }))

hl.bind(mainMod .. " + Left", hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + Right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + Up", hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + Down", hl.dsp.focus({ direction = "down" }))

hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + ALT + F", hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.window.float({ action = "toggle" }))

hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum brightness lower"), { locked = true })
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum brightness raise"), { locked = true })

hl.bind("Print", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum screenshot"), { locked = true })
hl.bind("SHIFT + Print", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum screenshot --edit"), { locked = true })
hl.bind("SUPER + Print", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum screenshot --full"), { locked = true })
hl.bind("SUPER + SHIFT + Print", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum screenshot --full --edit"), { locked = true })

hl.bind("XF86PowerOff", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum lock"), { locked = true })
hl.bind(mainMod .. " + L", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum lock"), { repeating = true, locked = true })

hl.bind(mainMod .. " + SPACE", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle launcher"))
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioMicMute", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum volume mic-toggle"), { locked = true })
hl.bind("XF86AudioMute", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum volume mute-toggle"), { locked = true })
hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum volume lower"), { repeating = true, locked = true })
hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum volume raise"), { repeating = true, locked = true })

hl.bind(mainMod .. " + F", hl.dsp.window.fullscreen({ mode = "fullscreen", action = "toggle" }))
hl.bind(mainMod .. " + E", hl.dsp.exec_cmd("thunar"))
hl.bind(mainMod .. " + RETURN", hl.dsp.exec_cmd(terminal))

hl.bind(mainMod .. " + R", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum reload"))
hl.bind(mainMod .. " + C", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle clipboard"))
hl.bind(mainMod .. " + D", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle launcher"))
hl.bind(mainMod .. " + M", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle music"))
hl.bind(mainMod .. " + B", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle system"))
hl.bind(mainMod .. " + W", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle wallpaper"))
hl.bind(mainMod .. " + S", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle calendar"))
hl.bind(mainMod .. " + N", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle network"))
hl.bind(mainMod .. " + V", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle clipboard"))
hl.bind(mainMod .. " + H", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle guide"))
hl.bind(mainMod .. " + A", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg toggle autohide"))

for i = 1, 10 do
  local ws = tostring(i)
  local key = tostring(i % 10)
  hl.bind(mainMod .. " + " .. key, hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg workspace " .. ws))
  hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum msg workspace " .. ws .. " move"))
end

-- Familiar shortcuts retained from the previous desktop.
hl.bind(mainMod .. " + T", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + Escape", hl.dsp.exec_cmd("$HOME/.local/bin/serpantinum lock"))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.workspace.toggle_special("magic"))
hl.bind(mainMod .. " + ALT + SHIFT + S", hl.dsp.window.move({ workspace = "special:magic" }))
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up", hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + Tab", hl.dsp.exec_cmd("hyprctl dispatch workspace previous"))
hl.bind("XF86KbdBrightnessUp", hl.dsp.exec_cmd('brightnessctl -d "*kbd_backlight*" set 10%+'), { repeating = true, locked = true })
hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd('brightnessctl -d "*kbd_backlight*" set 10%-'), { repeating = true, locked = true })
