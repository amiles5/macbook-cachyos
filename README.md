# macbook-cachyos

Dotfiles for CachyOS running on an Intel MacBook (T2) managed with [yadm](https://yadm.io/).

## System

- **Hardware**: Intel MacBook (T2 chip) dual-booting macOS + CachyOS
- **OS**: [CachyOS](https://cachyos.org/) (Arch-based)
- **Dotfile manager**: yadm

## Installation on a T2 MacBook

See the official CachyOS T2 MacBook installation guide:
https://wiki.cachyos.org/installation/installation_t2macbook/

## Wi-Fi Firmware

T2 MacBooks require proprietary firmware for Wi-Fi. If not already enabled from the live environment:

```bash
# Download the firmware package
curl https://mirror.funami.tech/arch-mact2/os/x86_64/apple-bcm-firmware-14.0-1-any.pkg.tar.zst -o apple-bcm-firmware-14.0-1-any.pkg.tar.zst

# Install it
sudo pacman -U apple-bcm-firmware-14.0-1-any.pkg.tar.zst

# Reload Wi-Fi kernel modules
sudo modprobe -r brcmfmac_wcc
sudo modprobe -r brcmfmac
sudo modprobe brcmfmac
```

Wi-Fi will now persist across reboots. You can remove the downloaded `.pkg.tar.zst` file.

## Tracked configs

| Path | Description |
|------|-------------|
| `~/.config/fish` | Fish shell config, functions, completions |
| `~/.config/kitty` | Kitty terminal emulator |
| `~/.config/ohmyposh` | Oh My Posh prompt themes |
| `~/.config/fastfetch` | Fastfetch system info display |
| `~/.config/swaylock` | Swaylock screen locker |
| `~/.config/hypr` | Hyprland compositor, hypridle, hyprlock |
| `~/.config/systemd/user` | User systemd services |
| `~/.local/bin` | User scripts |
| `~/.config/timeshift` | Timeshift backup config (symlinked from `/etc/timeshift/timeshift.json`) |

## Hyprland

Config is in `~/.config/hypr/hyprland.lua` using Hyprland's native Lua parser (not the legacy `.conf` format).

**Important:** `hyprctl reload` and `hyprctl keyword` do not work with the Lua parser.
- To apply config changes: log out and back in.
- To apply runtime changes: use `hyprctl eval 'hl.<function>(...)'`.

### Desktop shell

[noctalia-shell](https://git.sr.ht/~co1de/noctalia) via [QuickShell](https://quickshell.outfoxxed.me/) (`qs`). Started automatically on login.

IPC calls use the `--any-display` flag because `WAYLAND_DISPLAY` is not in the environment when Hyprland spawns commands:

```bash
qs -c noctalia-shell ipc --any-display call volume increase
qs -c noctalia-shell ipc --any-display call brightness increase
```

### Touch bar media keys

The touch bar runs in mode 2 (`hid_appletb_kbd`) which exposes standard XF86 keysyms. Hyprland binds these to noctalia IPC calls so volume and brightness changes show the noctalia OSD:

| Key | Action |
|-----|--------|
| Volume up/down | `qs ipc call volume increase/decrease` |
| Mute | `qs ipc call volume muteOutput` |
| Brightness up/down | `qs ipc call brightness increase/decrease` |
| Keyboard backlight up/down | `brightnessctl -d *::kbd_backlight set 5%+/-` |

Volume, brightness, and keyboard backlight keys all repeat when held.

### Monitors

| Output | Display | Position | Scale | Logical size |
|--------|---------|----------|-------|--------------|
| `DP-4` | LG Ultra HD 4K (external, left) | `0x0` | 2.6666 | ~1440×810 |
| `eDP-1` | MacBook built-in (right) | `1440x0` | 2 | 1440×900 |

Workspaces 1–5 are bound to `DP-4`; workspace 6 is bound to `eDP-1`. When `DP-4` is not connected, workspaces 1–5 fall back to `eDP-1` automatically.

### Lid close behaviour

A systemd user service (`hypr-lid-handler`) watches logind D-Bus for `LidClosed` events:

- **Lid closed**: `eDP-1` is disabled in Hyprland (removed from layout, mouse confined to `DP-4`)
- **Lid opened**: `eDP-1` is re-enabled at its configured position and scale

The service starts automatically with the graphical session. To check its status:

```bash
systemctl --user status hypr-lid-handler
```

## Power management

Lid switch behaviour is configured in `/etc/systemd/logind.conf.d/lid.conf`:

| Condition | Action |
|-----------|--------|
| Lid close on battery | Power off |
| Lid close on AC power | Ignore (machine stays up, `hypr-lid-handler` disables `eDP-1`) |
| Lid close when docked | Ignore |

## Setup on a new machine

```bash
# Install yadm
sudo pacman -S yadm

# Clone dotfiles
yadm clone git@github.com:amiles5/macbook-cachyos.git

# Symlink timeshift config
sudo ln -sf ~/.config/timeshift/timeshift.json /etc/timeshift/timeshift.json

# Enable lid handler service
systemctl --user enable --now hypr-lid-handler

# Configure lid switch (copy to /etc/systemd/logind.conf.d/lid.conf):
# [Login]
# HandleLidSwitch=poweroff
# HandleLidSwitchExternalPower=ignore
# HandleLidSwitchDocked=ignore
sudo mkdir -p /etc/systemd/logind.conf.d
# (create lid.conf manually with the above content)
sudo systemctl restart systemd-logind
```
