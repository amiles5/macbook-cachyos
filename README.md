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
| `~/.config/hypr` | Hyprland compositor, hypridle, hyprlock, lid-switch script |
| `~/.config/noctalia` | Noctalia shell settings |
| `~/.config/timeshift` | Timeshift backup config (symlinked from `/etc/timeshift/timeshift.json`) |
| `system/etc/...` | Reference copies of files that must live outside `$HOME` (yadm only tracks `$HOME`) — see [System files outside `$HOME`](#system-files-outside-home) |

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

### Lid close behaviour (clamshell mode)

Hyprland binds the lid switch directly — no separate daemon. In `hyprland.lua`:

```lua
local lidScript = "/home/milesj/.config/hypr/scripts/lid-switch.sh"
hl.bind("switch:on:Lid Switch",        hl.dsp.exec_cmd(lidScript .. " close"), { locked = true })
hl.bind("switch:off:Lid Switch",       hl.dsp.exec_cmd(lidScript .. " open"),  { locked = true })
hl.bind("switch:on:macsmc-chamshell",  hl.dsp.exec_cmd(lidScript .. " close"), { locked = true })
hl.bind("switch:off:macsmc-chamshell", hl.dsp.exec_cmd(lidScript .. " open"),  { locked = true })
```

Bound on both `Lid Switch` and `macsmc-chamshell` switch devices since it's unclear which one actually fires on this hardware (check with `hyprctl devices`); the script's commands are idempotent either way.

`~/.config/hypr/scripts/lid-switch.sh`:
- **close**: if on AC power *and* the external monitor (`DP-4`) is connected, disables `eDP-1`
- **open**: re-enables `eDP-1` at its configured mode/position/scale

An earlier version used a separate `hypr-lid-handler` systemd user service watching logind D-Bus — removed because it raced with these binds. Nothing needs to be enabled separately; the binds are active as soon as Hyprland loads the config.

## Power management

Lid switch behaviour is configured in `/etc/systemd/logind.conf.d/lid.conf`:

| Condition | Action |
|-----------|--------|
| Lid close on battery | Power off |
| Lid close on AC power | Ignore (machine stays up, `lid-switch.sh` disables `eDP-1`) |
| Lid close when docked | Ignore |

### AC power detection workaround

The `macsmc-power` kernel driver (T2 Macs) updates `/sys/class/power_supply/macsmc-ac/online` correctly but never fires a `change` uevent when the charger is plugged/unplugged. `upowerd` is event-driven (it doesn't poll sysfs), so it never notices — Noctalia's battery widget gets stuck showing whatever AC state was true at boot.

Two-part fix:

1. **`system/etc/systemd/system/macsmc-power-uevent-poll.{service,timer}`** — a timer that runs `udevadm trigger --action=change --subsystem-match=power_supply` every 5s, forcing upowerd to re-read the real state. Install:
   ```bash
   sudo cp ~/system/etc/systemd/system/macsmc-power-uevent-poll.{service,timer} /etc/systemd/system/
   sudo systemctl daemon-reload
   sudo systemctl enable --now macsmc-power-uevent-poll.timer
   ```

2. **`system/etc/xdg/quickshell/noctalia-shell/Services/Hardware/BatteryService.qml`** — patched copy of Noctalia's battery service. The `macsmc-battery` driver also reports `state: fully-charged` even while unplugged (charge thresholds cap charging at ~80%, so it never leaves the fully-charged state). Noctalia's `isPluggedIn()` trusted that state alone. The patch adds a real `acOnline` check gating `isPluggedIn()`. Install:
   ```bash
   sudo cp ~/system/etc/xdg/quickshell/noctalia-shell/Services/Hardware/BatteryService.qml /etc/xdg/quickshell/noctalia-shell/Services/Hardware/BatteryService.qml
   ```
   **Warning:** a `noctalia-qs` package update via pacman will overwrite this file — reapply after every update (diff against the mirrored copy first in case the upstream file changed structurally).

## Boot order / startup disk

CachyOS uses `systemd-boot`, registered as an EFI boot entry. On a fresh install (or after cloning), macOS is typically still first in the firmware's `BootOrder`, so the machine boots into macOS unless you hold Option at startup.

To make Linux the default:

```bash
# List current entries
efibootmgr -v

# Find the "Linux Boot Manager" (systemd-boot) entry number, e.g. 0002,
# and any "Fallback Linux Boot Manager" entry, e.g. 0003.
# Reorder so Linux boots first; keep macOS reachable as a fallback:
sudo efibootmgr -o 0002,0003,0080   # numbers vary per machine — check -v output first
```

If cloning to new hardware (or after a disk swap), stale boot entries may reference partition GUIDs that no longer exist on the current disk — `efibootmgr -v` will show a GUID that doesn't match any partition in `lsblk -o NAME,PARTUUID`. Delete those:

```bash
sudo efibootmgr -b <stale-entry> -B
```

`bootctl status` shows the actual currently-running loader (more trustworthy than `efibootmgr`'s `BootCurrent`, which can be stale on this hardware).

## Cloning to identical hardware (T2 MacBook)

Use [Clonezilla](https://clonezilla.org/) to image the full disk to a new T2 MacBook.

### Before imaging — prepare the target machine

The T2 chip blocks booting from external media by default. On the **target** MacBook:

1. Boot into macOS Recovery (`Cmd+R` at startup)
2. Open **Startup Security Utility**
3. Set security to **No Security**
4. Enable **Allow booting from external media**

### Create the image (source machine)

1. Boot the source MacBook from a Clonezilla USB
2. Choose **device-to-image** → save to an external disk
3. Select the internal disk (e.g. `nvme0n1`) as the source

### Restore the image (target machine)

1. Boot the target MacBook from the Clonezilla USB
2. Choose **image-to-device** → select the saved image
3. Select the target internal disk as the destination

### If the target disk is larger

Clonezilla copies the partition layout exactly. Expand the Btrfs partition after booting into CachyOS:

```bash
# Expand the partition to fill the disk (use your partition tool, e.g. parted)
sudo btrfs filesystem resize max /
```

### After restoring

The cloned machine is a full copy — no further setup needed. If you later want to re-sync dotfile changes from this repo:

```bash
yadm pull
```

---

## System files outside `$HOME`

yadm only tracks `$HOME`, so anything that must live under `/etc` is instead kept as a reference copy in this repo under `system/`, mirroring its real absolute path (e.g. `system/etc/systemd/system/foo.service` installs to `/etc/systemd/system/foo.service`). These are **not** symlinked automatically — copy them into place manually (see install steps in each relevant section above: [AC power detection workaround](#ac-power-detection-workaround), [Lid close behaviour](#lid-close-behaviour-clamshell-mode)).

## Setup on a new machine

```bash
# Install yadm
sudo pacman -S yadm

# Clone dotfiles
yadm clone git@github.com:amiles5/macbook-cachyos.git

# Symlink timeshift config
sudo ln -sf ~/.config/timeshift/timeshift.json /etc/timeshift/timeshift.json

# Configure lid switch (copy to /etc/systemd/logind.conf.d/lid.conf):
# [Login]
# HandleLidSwitch=poweroff
# HandleLidSwitchExternalPower=ignore
# HandleLidSwitchDocked=ignore
sudo mkdir -p /etc/systemd/logind.conf.d
# (create lid.conf manually with the above content)
sudo systemctl restart systemd-logind

# Install the AC-power uevent workaround timer
sudo cp ~/system/etc/systemd/system/macsmc-power-uevent-poll.{service,timer} /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now macsmc-power-uevent-poll.timer

# Patch Noctalia's battery service (reapply after every noctalia-qs update)
sudo cp ~/system/etc/xdg/quickshell/noctalia-shell/Services/Hardware/BatteryService.qml \
        /etc/xdg/quickshell/noctalia-shell/Services/Hardware/BatteryService.qml

# Set Linux as the default startup disk (see "Boot order / startup disk" above
# for how to find your entry numbers)
sudo efibootmgr -o <linux-entry>,<linux-fallback-entry>,<macos-entry>
```

Note: `~/.config/hypr/scripts/lid-switch.sh` and Hyprland's `switch:on/off` binds are already tracked and active as soon as Hyprland loads — no separate install step needed for clamshell mode.
