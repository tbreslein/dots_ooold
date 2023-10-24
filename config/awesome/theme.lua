local gears = require("gears")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local theme = {}

theme.font = "Hack Nerd Font Bold 15"
theme.tag_font = "Hack Nerd Font 20"

theme.bg_normal = "#282828"
theme.bg_focus = "#5a524c"
theme.bg_urgent = "#402120"
theme.bg_minimize = "#3c3836"
theme.bg_systray = theme.bg_normal

theme.fg_normal = "#d4be98"
theme.fg_focus = "#d8a657"
theme.fg_urgent = "#ea6962"
theme.fg_minimize = "#d3869b"

theme.useless_gap = dpi(8)
theme.border_width = dpi(3)
theme.border_normal = "#282828"
theme.border_focus = "#ddc7a1"
theme.border_marked = "#d8a657"

-- There are other variable sets
-- overriding the default one when
-- defined, the sets are:
-- taglist_[bg|fg]_[focus|urgent|occupied|empty|volatile]
-- tasklist_[bg|fg]_[focus|urgent]
-- titlebar_[bg|fg]_[normal|focus]
-- tooltip_[font|opacity|fg_color|bg_color|border_width|border_color]
-- mouse_finder_[color|timeout|animate_timeout|radius|factor]
-- prompt_[fg|bg|fg_cursor|bg_cursor|font]
-- hotkeys_[bg|fg|border_width|border_color|shape|opacity|modifiers_fg|label_bg|label_fg|group_margin|font|description_font]
-- Example:
--theme.taglist_bg_focus = "#ff0000"

-- Variables set for theming notifications:
-- notification_font
-- notification_[bg|fg]
-- notification_[width|height|margin]
-- notification_[border_color|border_width|shape|opacity]
theme.notification_font = "Noto Sans 15"
theme.notification_bg = "#282828"
theme.notification_fg = "#d4be98"
theme.notification_border_color = "#d4be98"
theme.notification_shape = function(cr, width, height)
    gears.shape.rounded_rect(cr, width, height, 7)
end

-- You can add as many variables as
-- you wish and access them by using
-- beautiful.variable in your rc.lua
--theme.bg_widget = "#cc0000"

-- Define the icon theme for application icons. If not set then the icons
-- from /usr/share/icons and /usr/share/icons/hicolor will be used.
theme.icon_theme = nil

return theme

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
