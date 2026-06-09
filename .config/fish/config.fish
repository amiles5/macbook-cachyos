source /usr/share/cachyos-fish-config/cachyos-config.fish
fish_add_path ~/.local/bin
zoxide init fish --cmd cd | source

# Override eza aliases from cachyos-config with standard ls
alias ls='command ls --color=always --group-directories-first'
alias la='command ls -a --color=always --group-directories-first'
alias ll='command ls -latrh --color=always --group-directories-first'
alias lt='command ls -aR --color=always'
alias l.='command ls -a | grep -e "^\."'
oh-my-posh init fish --config /home/milesj/.config/ohmyposh/agnoster.omp.json | source

# overwrite greeting
# potentially disabling fastfetch
#function fish_greeting
#    # smth smth
#end
