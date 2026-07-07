-- Hyprland Configuration
-- https://wiki.hyprland.org/Configuring/

hl.config({
    debug = {
        disable_logs = false,
    },
    general = {
        gaps_in     = 5,
        gaps_out    = 5,
        border_size = 2,
        -- https://wiki.hyprland.org/Configuring/Variables/#variable-types
        col = { active_border   = { colors = { "rgba(33ccffee)", "rgba(00ff99ee)" }, angle = 45 } },
        col = { inactive_border = "rgba(595959aa)" },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },
    decoration = {
        rounding         = 10,
        active_opacity   = 1.0,
        inactive_opacity = 1.0,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            color        = "rgba(1a1a1aee)",
        },
        -- https://wiki.hyprland.org/Configuring/Variables/#blur
        blur = {
            enabled  = true,
            size     = 3,
            passes   = 1,
            vibrancy = 0.1696,
        },
    },
    master = {
        new_status = "master",
    },
    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },
    input = {
        kb_layout    = "gb",
        kb_model     = "apple",
        kb_variant   = "mac",
--        kb_model     = "pc105",
--        kb_options   = "terminate:ctrl_alt_bksp",
--       kb_rules     = "evdev",
        follow_mouse = 1,
        sensitivity  = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
    xwayland = {
        force_zero_scaling   = false,
        use_nearest_neighbor = false,
    },
})

-- ─── Monitors ────────────────────────────────────────────────────────────────

-- LG Ultra HD 4K: left monitor, scale 2.6666 → ~1440x810 logical
hl.monitor({ output = "DP-4",  mode = "3840x2160@60", position = "0x0",    scale = 2.6666 })
-- MacBook built-in: right of DP-4, scale 2 → 1440x900 logical
hl.monitor({ output = "eDP-1", mode = "2880x1800@60", position = "1440x0", scale = 2.666666})

-- ─── Workspaces ──────────────────────────────────────────────────────────────

-- Workspaces 1-5 on DP-4 when connected, fall back to eDP-1 when not
hl.workspace_rule({ workspace = "1", monitor = "DP-4" })
hl.workspace_rule({ workspace = "2", monitor = "DP-4" })
hl.workspace_rule({ workspace = "3", monitor = "DP-4" })
hl.workspace_rule({ workspace = "4", monitor = "DP-4" })
hl.workspace_rule({ workspace = "5", monitor = "DP-4" })
-- Workspace 6 always on eDP-1
hl.workspace_rule({ workspace = "6", monitor = "eDP-1" })

-- ─── Startup ─────────────────────────────────────────────────────────────────

hl.on("hyprland.start", function()
    hl.exec_cmd("hypridle")
--    hl.exec_cmd("noctalia-shell &")
    hl.exec_cmd("qs -c noctalia-shell")

    -- ─── Programs ────────────────────────────────────────────────────────────

    local terminal    = "kitty"
    local fileManager = "dolphin"
    local menu        = "wofi --show drun"

    -- ─── Environment Variables ───────────────────────────────────────────────
    -- https://wiki.hyprland.org/Configuring/Environment-variables/

    hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
    hl.env("XCURSOR_SIZE",        "24")
    hl.env("HYPRCURSOR_SIZE",     "24")

    -- ─── Animations ──────────────────────────────────────────────────────────

    hl.curve("easeOutQuint",   { type = "bezier", points = { { 0.23, 1    }, { 0.32, 1   } } })
    hl.curve("easeInOutCubic", { type = "bezier", points = { { 0.65, 0.05 }, { 0.36, 1   } } })
    hl.curve("linear",         { type = "bezier", points = { { 0,    0    }, { 1,    1   } } })
    hl.curve("almostLinear",   { type = "bezier", points = { { 0.5,  0.5  }, { 0.75, 1.0 } } })
    hl.curve("quick",          { type = "bezier", points = { { 0.15, 0    }, { 0.1,  1   } } })

    hl.animation({ leaf = "global",        enabled = true, speed = 10,   bezier = "default"      })
    hl.animation({ leaf = "border",        enabled = true, speed = 5.39, bezier = "easeOutQuint"  })
    hl.animation({ leaf = "windows",       enabled = true, speed = 4.79, bezier = "easeOutQuint"  })
    hl.animation({ leaf = "windowsIn",     enabled = true, speed = 4.1,  bezier = "easeOutQuint",  style = "popin 87%" })
    hl.animation({ leaf = "windowsOut",    enabled = true, speed = 1.49, bezier = "linear",        style = "popin 87%" })
    hl.animation({ leaf = "fadeIn",        enabled = true, speed = 1.73, bezier = "almostLinear"  })
    hl.animation({ leaf = "fadeOut",       enabled = true, speed = 1.46, bezier = "almostLinear"  })
    hl.animation({ leaf = "fade",          enabled = true, speed = 3.03, bezier = "quick"         })
    hl.animation({ leaf = "layers",        enabled = true, speed = 3.81, bezier = "easeOutQuint"  })
    hl.animation({ leaf = "layersIn",      enabled = true, speed = 4,    bezier = "easeOutQuint",  style = "fade" })
    hl.animation({ leaf = "layersOut",     enabled = true, speed = 1.5,  bezier = "linear",        style = "fade" })
    hl.animation({ leaf = "fadeLayersIn",  enabled = true, speed = 1.79, bezier = "almostLinear"  })
    hl.animation({ leaf = "fadeLayersOut", enabled = true, speed = 1.39, bezier = "almostLinear"  })
    hl.animation({ leaf = "workspaces",    enabled = true, speed = 1.94, bezier = "almostLinear",  style = "fade" })
    hl.animation({ leaf = "workspacesIn",  enabled = true, speed = 1.21, bezier = "almostLinear",  style = "fade" })
    hl.animation({ leaf = "workspacesOut", enabled = true, speed = 1.94, bezier = "almostLinear",  style = "fade" })

    -- ─── Keybindings ─────────────────────────────────────────────────────────

    local mainMod = "SUPER"

    -- Applications
    hl.bind(mainMod .. " + SHIFT + RETURN", hl.dsp.exec_cmd("[workspace 2] firefox"))
    hl.bind(mainMod .. " + C",              hl.dsp.exec_cmd("[workspace 2] firefox --name ff-work -P sonos https://play.sonos.com --no-remote"))
    hl.bind(mainMod .. " + J",              hl.dsp.exec_cmd("[workspace 3] joplin-desktop"))
    hl.bind(mainMod .. " + RETURN",         hl.dsp.exec_cmd("[workspace 1] " .. terminal))

    -- Window management
    hl.bind(mainMod .. " + W",     hl.dsp.window.close())
    hl.bind(mainMod .. " + LEFT",  hl.dsp.focus({ direction = "l" }))
    hl.bind(mainMod .. " + RIGHT", hl.dsp.focus({ direction = "r" }))
    hl.bind(mainMod .. " + UP",    hl.dsp.focus({ direction = "u" }))
    hl.bind(mainMod .. " + DOWN",  hl.dsp.focus({ direction = "d" }))

    -- Workspace navigation
    hl.bind(mainMod .. " + TAB",         hl.dsp.focus({ workspace = "e+1" }))
    hl.bind(mainMod .. " + SHIFT + TAB", hl.dsp.focus({ workspace = "e-1" }))
    hl.bind(mainMod .. " + mouse_down",  hl.dsp.focus({ workspace = "r-1" }))
    hl.bind(mainMod .. " + mouse_up",    hl.dsp.focus({ workspace = "r+1" }))

    hl.bind(mainMod .. " + 1", hl.dsp.focus({ workspace = "1" }))
    hl.bind(mainMod .. " + 2", hl.dsp.focus({ workspace = "2" }))
    hl.bind(mainMod .. " + 3", hl.dsp.focus({ workspace = "3" }))
    hl.bind(mainMod .. " + 4", hl.dsp.focus({ workspace = "4" }))
    hl.bind(mainMod .. " + 5", hl.dsp.focus({ workspace = "5" }))
    hl.bind(mainMod .. " + 6", hl.dsp.focus({ workspace = "6" }))

    -- Move windows to workspace
    hl.bind(mainMod .. " + SHIFT + 1", hl.dsp.window.move({ workspace = "1" }))
    hl.bind(mainMod .. " + SHIFT + 2", hl.dsp.window.move({ workspace = "2" }))
    hl.bind(mainMod .. " + SHIFT + 3", hl.dsp.window.move({ workspace = "3" }))
    hl.bind(mainMod .. " + SHIFT + 4", hl.dsp.window.move({ workspace = "4" }))
    hl.bind(mainMod .. " + SHIFT + 5", hl.dsp.window.move({ workspace = "5" }))
    hl.bind(mainMod .. " + SHIFT + 6", hl.dsp.window.move({ workspace = "6" }))

    -- Mouse
    hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(), { mouse = true })
    hl.bind(mainMod .. " + mouse:273", hl.dsp.window.drag(), { mouse = true })

    -- Media keys
    hl.bind("XF86AudioRaiseVolume", hl.dsp.exec_cmd("qs -c noctalia-shell ipc --any-display call volume increase"),   { repeating = true, locked = true })
    hl.bind("XF86AudioLowerVolume", hl.dsp.exec_cmd("qs -c noctalia-shell ipc --any-display call volume decrease"),   { repeating = true, locked = true })
    hl.bind("XF86AudioMute",        hl.dsp.exec_cmd("qs -c noctalia-shell ipc --any-display call volume muteOutput"), { locked = true })
    hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("qs -c noctalia-shell ipc --any-display call brightness increase"), { repeating = true, locked = true })
    hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("qs -c noctalia-shell ipc --any-display call brightness decrease"), { repeating = true, locked = true })
    hl.bind("XF86KbdBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 5%+"), { repeating = true, locked = true })
    hl.bind("XF86KbdBrightnessDown", hl.dsp.exec_cmd("brightnessctl -d *::kbd_backlight set 5%-"), { repeating = true, locked = true })

    -- Clamshell mode: disable internal display on lid close when on AC power
    -- with an external monitor connected; re-enable on lid open.
    -- Bound on both switch devices since it's unclear which one actually
    -- fires on this hardware (see `hyprctl devices`); commands are idempotent.
    local lidScript = "/home/milesj/.config/hypr/scripts/lid-switch.sh"
    hl.bind("switch:on:Lid Switch",        hl.dsp.exec_cmd(lidScript .. " close"), { locked = true })
    hl.bind("switch:off:Lid Switch",       hl.dsp.exec_cmd(lidScript .. " open"),  { locked = true })
    hl.bind("switch:on:macsmc-chamshell",  hl.dsp.exec_cmd(lidScript .. " close"), { locked = true })
    hl.bind("switch:off:macsmc-chamshell", hl.dsp.exec_cmd(lidScript .. " open"),  { locked = true })
end)
