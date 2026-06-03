#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc

# Added by Toolbox App
export PATH="$PATH:/home/nanda-kumudhan/.local/share/JetBrains/Toolbox/scripts"

[ -r "$HOME/.config/sway/scripts/session-env" ] && . "$HOME/.config/sway/scripts/session-env"
