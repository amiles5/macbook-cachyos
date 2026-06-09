# macbook-cachyos

Dotfiles for CachyOS running on an Intel MacBook (T2) managed with [yadm](https://yadm.io/).

## System

- **Hardware**: Intel MacBook (T2 chip) dual-booting macOS + CachyOS
- **OS**: [CachyOS](https://cachyos.org/) (Arch-based)
- **Dotfile manager**: yadm

## Installation on a T2 MacBook

See the official CachyOS T2 MacBook installation guide:
https://wiki.cachyos.org/installation/installation_t2macbook/

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
