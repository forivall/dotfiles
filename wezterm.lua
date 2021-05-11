local wezterm = require 'wezterm';
return {
  default_prog = {"/usr/local/bin/zsh"},
  freetype_load_target = "Light",
  freetype_load_flags = "NO_HINTING",
  font = wezterm.font("FantasqueSansMono Nerd Font", {}),
  font_size=12.24,
  line_height=1.1,
  font_antialias="Subpixel",
  color_scheme = "Tomorrow Night",
  -- colors = {
  --   -- The default text color
  --   foreground = "silver",
  --   -- The default background color
  --   background = "black",

  --   -- Overrides the cell background color when the current cell is occupied by the
  --   -- cursor and the cursor style is set to Block
  --   cursor_bg = "#52ad70",
  --   -- Overrides the text color when the current cell is occupied by the cursor
  --   cursor_fg = "black",
  --   -- Specifies the border color of the cursor when the cursor style is set to Block,
  --   -- of the color of the vertical or horizontal bar when the cursor style is set to
  --   -- Bar or Underline.
  --   cursor_border = "#52ad70",

  --   -- the foreground color of selected text
  --   selection_fg = "black",
  --   -- the background color of selected text
  --   selection_bg = "#fffacd",

  --   -- The color of the scrollbar "thumb"; the portion that represents the current viewport
  --   scrollbar_thumb = "#222222",

  --   -- The color of the split lines between panes
  --   split = "#444444",

  --   ansi = {"black", "maroon", "green", "olive", "navy", "purple", "teal", "silver"},
  --   brights = {"grey", "red", "lime", "yellow", "blue", "fuchsia", "aqua", "white"},
  -- },
}
