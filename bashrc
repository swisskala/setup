# If not running interactively, don't do anything
[[ $- != *i* ]] && return
alias la='ls -ahl --color=auto'
alias ll='ls -lh --color=auto'
alias ls='ls --color=auto'
alias lsd='lsd -lh'
alias lsda='lsd -alh'
alias startw='startplasma-wayland'
alias stopx='i3-msg exit'

# Enhanced cd function - auto-list directory contents with lsd
cd() {
  builtin cd "$@" && lsd -a
}

# Custom aliases added by setup script

# Mini manpages for installed commands - added by setup script
commandman() {
    echo -e "\e[1;36m=== INSTALLED COMMANDS - QUICK REFERENCE ===\e[0m"
    echo ""
    echo -e "\e[1;33mTERMINAL & SYSTEM:\e[0m"
    echo -e "  \e[1;32mkitty\e[0m         - Modern GPU-accelerated terminal emulator"
    echo -e "  \e[1;32mmc\e[0m            - Midnight Commander file manager"
    echo -e "  \e[1;32mbtop\e[0m          - Interactive system monitor (CPU, memory, processes)"
    echo -e "  \e[1;32mncdu\e[0m          - NCurses disk usage analyzer - find what uses space"
    echo -e "  \e[1;32mtealdeer\e[0m      - Fast tldr client for simplified command help (use: tldr)"
    echo ""
    echo -e "\e[1;33mFILE OPERATIONS:\e[0m"
    echo -e "  \e[1;32munzip\e[0m         - Extract ZIP archives"
    echo -e "  \e[1;32mlsd\e[0m           - Modern ls with colors and icons"
    echo ""
    echo -e "\e[1;33mFILE LISTING ALIASES:\e[0m"
    echo -e "  \e[1;35mla\e[0m            - List all files with details (ls -ahl --color=auto)"
    echo -e "  \e[1;35mll\e[0m            - List files with details (ls -lh --color=auto)"
    echo -e "  \e[1;35mls\e[0m            - List files with colors (ls --color=auto)"
    echo -e "  \e[1;35mlsd\e[0m           - List with lsd in detailed format (lsd -lh)"
    echo -e "  \e[1;35mlsda\e[0m          - List all files with lsd detailed (lsd -alh)"
    echo ""
    echo -e "\e[1;33mDESKTOP ENVIRONMENT:\e[0m"
    echo -e "  \e[1;35mstartw\e[0m        - Start KDE Plasma Wayland session"
    echo -e "  \e[1;35mstopx\e[0m         - Exit i3 window manager"
    echo ""
    echo -e "\e[1;33mUSAGE EXAMPLES:\e[0m"
    echo -e "  \e[1;34mbtop\e[0m                    # Monitor system resources"
    echo -e "  \e[1;34mncdu /home\e[0m              # Analyze disk usage in /home"
    echo -e "  \e[1;34mlsd\e[0m                     # Pretty file listing"
    echo -e "  \e[1;34mkitty &\e[0m                 # Launch new terminal"
    echo -e "  \e[1;34munzip archive.zip\e[0m       # Extract zip file"
    echo -e "  \e[1;34mtldr ls\e[0m                 # Quick help for ls command"
    echo -e "  \e[1;34mtldr --update\e[0m           # Update tldr database"
    echo ""
    echo -e "\e[1;33mTAR EXAMPLES:\e[0m"
    echo -e "  \e[1;34mtar -xzf archive.tar.gz\e[0m # Extract .tar.gz file"
    echo -e "  \e[1;34mtar -xjf archive.tar.bz2\e[0m# Extract .tar.bz2 file"
    echo -e "  \e[1;34mtar -czf backup.tar.gz dir/\e[0m# Create .tar.gz archive"
    echo -e "  \e[1;34mtar -tf archive.tar\e[0m     # List contents without extracting"
    echo ""
    echo -e "\e[1;37mType 'man <command>' or 'tldr <command>' for documentation.\e[0m"
}

# Colorful bash prompt - added by setup script
# Format: [blue]username[reset]@[red]hostname[reset]:path$ 
PS1='\[\e[1;34m\]\u\[\e[0m\]@\[\e[1;31m\]\h\[\e[0m\]:\w$ '

# Shortcut alias for commandman - added by setup script
alias cmds='commandman'
