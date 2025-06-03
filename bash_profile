#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Show system info on TTY login
if [[ $(tty) == /dev/tty* ]]; then
  fastfetch
fi

export FILEMANAGER=dolphin
export GTK_THEME=Adwaita:dark dmenu_run
