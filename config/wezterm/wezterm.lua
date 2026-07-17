local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.colors = require("color.cyberdream")

config.font_size = 19

config.enable_tab_bar = false

config.window_decorations = "RESIZE"
config.window_background_opacity = 0.98

config.term = "xterm-256color"
config.enable_kitty_graphics = true
config.macos_window_background_blur = 1001
config.max_fps = 120

return config
