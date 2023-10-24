---@diagnostic disable: undefined-global
-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
local wibox = require("wibox") -- Widget and layout library
local beautiful = require("beautiful") -- Theme handling library
local naughty = require("naughty") -- Notification library

-- === Error handling
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors,
    })
end
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then
            return
        end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err),
        })
        in_error = false
    end)
end

-- === Variable definitions ===
beautiful.init("~/.config/awesome/theme.lua")
Terminal = "alacritty"
Editor = os.getenv("EDITOR") or "Editor"
Editor_cmd = Terminal .. " -e " .. Editor
Modkey = "Mod4"
awful.layout.layouts = {
    awful.layout.suit.tile.left,
    awful.layout.suit.floating,
    awful.layout.suit.max.fullscreen,
}

-- === Wibar ===
-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t)
        t:view_only()
    end),
    awful.button({ Modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ Modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t)
        awful.tag.viewnext(t.screen)
    end),
    awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end)
)

Systray = wibox.widget.systray()
Systray:set_base_size(30)
awful.screen.connect_for_each_screen(function(s)
    awful.tag({ " ", "󰖟 ", " " }, s, awful.layout.layouts[1])
    s.mytaglist = awful.widget.taglist({
        screen = s,
        filter = awful.widget.taglist.filter.all,
        buttons = taglist_buttons,
        layout = wibox.layout.fixed.horizontal,
        style = {
            font = beautiful.tag_font,
        },
    })

    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        widget = wibox.container.background,
        shape = function(cr, width, height)
            gears.shape.rounded_rect(cr, width, height, 7)
        end,
    })
    s.mywibox:setup({
        layout = wibox.layout.align.horizontal,
        {
            layout = wibox.layout.fixed.horizontal,
            s.mytaglist,
        },
        {
            layout = wibox.layout.align.horizontal,
            expand = "outside",
            nil,
            wibox.widget.textclock("%H:%M"),
            nil,
        },
        {
            layout = wibox.layout.fixed.horizontal,
            Systray,
        },
    })
end)

-- {{{ Key bindings
Globalkeys = gears.table.join(
    awful.key({ Modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
    awful.key({ Modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),
    awful.key({ Modkey, "Shift" }, "j", function()
        awful.client.focus.byidx(1)
    end, { description = "focus next by index", group = "client" }),
    awful.key({ Modkey, "Shift" }, "k", function()
        awful.client.focus.byidx(-1)
    end, { description = "focus previous by index", group = "client" }),
    awful.key({ Modkey, "Control" }, "j", function()
        awful.client.swap.byidx(1)
    end, { description = "swap with next client by index", group = "client" }),
    awful.key({ Modkey, "Control" }, "k", function()
        awful.client.swap.byidx(-1)
    end, { description = "swap with previous client by index", group = "client" }),
    awful.key({ Modkey, "Shift" }, ".", function()
        awful.screen.focus_relative(1)
    end, { description = "focus the next screen", group = "screen" }),
    awful.key({ Modkey, "Shift" }, ",", function()
        awful.screen.focus_relative(-1)
    end, { description = "focus the previous screen", group = "screen" }),
    awful.key({ Modkey }, "Return", function()
        awful.spawn(Terminal)
    end, { description = "open a terminal", group = "launcher" }),
    awful.key({ Modkey }, "space", function()
        awful.spawn(
            "dmenu_run -i -p 'dmenu_run'"
                .. " -fn 'Hack:size=15'"
                .. " -nb '#1b1b1b'"
                .. " -nf '#d4be98'"
                .. " -sb '#5a524c'"
                .. " -sf '#d8a657'"
        )
    end, { description = "open dmenu", group = "launcher" }),
    awful.key({ Modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
    awful.key({ Modkey, "Control" }, "x", awesome.quit, { description = "quit awesome", group = "awesome" }),
    awful.key({ Modkey, "Control" }, "l", function()
        awful.tag.incmwfact(0.05)
    end, { description = "increase master width factor", group = "layout" }),
    awful.key({ Modkey, "Control" }, "h", function()
        awful.tag.incmwfact(-0.05)
    end, { description = "decrease master width factor", group = "layout" }),
    awful.key({ Modkey, "Control" }, "n", function()
        local c = awful.client.restore()
        -- Focus restored client
        if c then
            c:emit_signal("request::activate", "key.unminimize", { raise = true })
        end
    end, { description = "restore minimized", group = "client" })
)

Clientkeys = gears.table.join(
    awful.key({ Modkey, "Control" }, "f", function(c)
        c.fullscreen = not c.fullscreen
        c:raise()
    end, { description = "toggle fullscreen", group = "client" }),
    awful.key({ Modkey, "Control" }, "q", function(c)
        c:kill()
    end, { description = "close", group = "client" }),
    awful.key(
        { Modkey, "Control" },
        "v",
        awful.client.floating.toggle,
        { description = "toggle floating", group = "client" }
    ),
    awful.key({ Modkey, "Control" }, "Return", function(c)
        c:swap(awful.client.getmaster())
    end, { description = "move to master", group = "client" }),
    awful.key({ Modkey, "Control" }, "o", function(c)
        c:move_to_screen()
    end, { description = "move to screen", group = "client" }),
    awful.key({ Modkey, "Shift" }, "n", function(c)
        -- The client currently has the input focus, so it cannot be
        -- minimized, since minimized clients can't have the focus.
        c.minimized = true
    end, { description = "minimize", group = "client" }),
    awful.key({ Modkey, "Shift" }, "m", function(c)
        c.maximized = not c.maximized
        c:raise()
    end, { description = "(un)maximize", group = "client" })
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    Globalkeys = gears.table.join(
        Globalkeys,
        -- View tag only.
        awful.key({ Modkey }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                tag:view_only()
            end
        end, { description = "view tag #" .. i, group = "tag" }),
        -- Toggle tag display.
        awful.key({ Modkey, "Control" }, "#" .. i + 9, function()
            local screen = awful.screen.focused()
            local tag = screen.tags[i]
            if tag then
                awful.tag.viewtoggle(tag)
            end
        end, { description = "toggle tag #" .. i, group = "tag" }),
        -- Move client to tag.
        awful.key({ Modkey, "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:move_to_tag(tag)
                end
            end
        end, { description = "move focused client to tag #" .. i, group = "tag" }),
        -- Toggle tag on focused client.
        awful.key({ Modkey, "Control", "Shift" }, "#" .. i + 9, function()
            if client.focus then
                local tag = client.focus.screen.tags[i]
                if tag then
                    client.focus:toggle_tag(tag)
                end
            end
        end, { description = "toggle focused client on tag #" .. i, group = "tag" })
    )
end

Clientbuttons = gears.table.join(
    awful.button({}, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
    end),
    awful.button({ Modkey }, 1, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.move(c)
    end),
    awful.button({ Modkey }, 3, function(c)
        c:emit_signal("request::activate", "mouse_click", { raise = true })
        awful.mouse.client.resize(c)
    end)
)

-- Set keys
root.keys(Globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = Clientkeys,
            buttons = Clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        },
    },

    -- Note that the name property shown in xprop might be set slightly after creation of the client
    -- and the name shown there might not match defined rules here.
    -- Floating clients.
    {
        rule_any = {
            instance = { "copyq", "pinentry" },
            class = { "megasync", "Arandr", "Blueman-manager" },
            name = { "MEGAsync", "Event Tester" }, -- xev
            role = { "pop-up" }, -- e.g. Google Chrome's (detached) Developer Tools.
        },
        properties = { floating = true },
    },

    {
        rule = { name = "Picture in picture" },
        properties = { floating = true, sticky = true, titlebars_enabled = false },
    },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
end)
-- }}}

awful.spawn.with_shell("~/.config/awesome/autorun.sh")
