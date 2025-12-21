local wezterm = require 'wezterm'

local config = wezterm.config_builder()

-- local modal = wezterm.plugin.require 'https://github.com/MLFlexer/modal.wezterm'
-- modal.enable_defaults("https://github.com/MLFlexer/modal.wezterm")
-- modal.apply_to_config(config)

local toggle_terminal = wezterm.plugin.require("https://github.com/zsh-sage/toggle_terminal.wez")
toggle_terminal.apply_to_config(config, {
  
})

config.bold_brightens_ansi_colors = false

config.colors = {
  foreground = '#D0D2D1',
  background = '#27292b',

  cursor_bg = '#D0D2D1',
  cursor_fg = '#27292C',

  selection_bg = '#534C53',
  selection_fg = '#D0D2D1',

  ansi = {
    '#000000', -- black (0)
    '#e19590', -- red (1)
    '#c8cc89', -- green (2)
    '#edd090', -- yellow (3)
    '#98b0c7', -- blue (4)
    '#bba7c4', -- magenta (5)
    '#a3c7c3', -- cyan (6)
    '#fefefe', -- white (7)
  },

  brights = {
    '#191815', -- black (8)
    '#c67c78', -- red (9)
    '#b1b574', -- green (10)
    '#ccb071', -- yellow (11)
    '#7a91a6', -- blue (12)
    '#9c87a4', -- magenta (13)
    '#84a6a3', -- cyan (14)
    '#dddddd', -- white (15)
  },
}

-- config.default_prog = {"/usr/local/bin/zsh"}
config.freetype_load_target = "Light"
config.freetype_load_flags = "NO_HINTING"
config.font = wezterm.font("FantasqueSansM Nerd Font Mono", {})
config.font_size=12.24
config.line_height=1.1
-- config.font_antialias="Subpixel"
config.color_scheme = "Tomorrow Night"
config.scrollback_lines = 200000
config.window_background_opacity = 1.0
config.window_background_gradient = {
  colors = { '#27292b', '#27292b' },
  -- Specifies a Linear gradient starting in the top left corner.
  -- orientation = { Linear = { angle = -45.0 } },
}
config.background = {
  {
    source = {
      File = '<gdrive>/Pictures/Wallpapers/Japan daylight savings_tiler_blur.jpg',
    },
    width = 1920,
    height = 2160,
    opacity = 0.08,
    -- hsb = { brightness = 0.08 }
  }
}

return config
