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

| Directory | Description |
|-----------|-------------|
| `~/.config/fish` | Fish shell config, functions, completions |
| `~/.config/kitty` | Kitty terminal emulator |
| `~/.config/ohmyposh` | Oh My Posh prompt themes |
| `~/.config/fastfetch` | Fastfetch system info display |
| `~/.config/swaylock` | Swaylock screen locker |
| `~/.config/hypr` | Hyprland compositor, hypridle, hyprlock |
| `~/.config/timeshift` | Timeshift backup config (symlinked from `/etc/timeshift/timeshift.json`) |

## Setup on a new machine

```bash
# Install yadm
sudo pacman -S yadm

# Clone dotfiles
yadm clone git@github.com:amiles5/macbook-cachyos.git

# Symlink timeshift config
sudo ln -sf ~/.config/timeshift/timeshift.json /etc/timeshift/timeshift.json
```
