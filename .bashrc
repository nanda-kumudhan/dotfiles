#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Let terminal editors receive Ctrl-S/Ctrl-Q as normal shortcuts.
stty -ixon 2>/dev/null

alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Fallback prompt and CLI colours. Starship takes over PS1 when available.
PS1='\[\e[38;2;238;238;238m\]\W\[\e[38;2;170;170;170m\] \$\[\e[0m\] '
export LS_COLORS='di=1;38;2;238;238;238:ln=38;2;170;170;170:ex=1;38;2;204;204;204:*.tar=38;2;170;170;170:*.tgz=38;2;170;170;170:*.zip=38;2;170;170;170:*.gz=38;2;170;170;170:*.xz=38;2;170;170;170:*.7z=38;2;170;170;170:*.jpg=38;2;187;187;187:*.jpeg=38;2;187;187;187:*.png=38;2;187;187;187:*.gif=38;2;187;187;187:*.mp4=38;2;187;187;187:*.mkv=38;2;187;187;187:*.mp3=38;2;187;187;187:*.flac=38;2;187;187;187:*.rs=38;2;204;204;204:*.py=38;2;204;204;204:*.js=38;2;204;204;204:*.ts=38;2;204;204;204:*.go=38;2;204;204;204:*.c=38;2;204;204;204:*.cpp=38;2;204;204;204:*.java=38;2;204;204;204:*.rb=38;2;204;204;204'
export GREP_COLORS='ms=01;38;2;238;238;238:mc=01;38;2;238;238;238:sl=:cx=:fn=38;2;170;170;170:ln=38;2;136;136;136:bn=38;2;136;136;136:se=38;2;136;136;136'
export LESS_TERMCAP_md=$'\e[1;38;2;238;238;238m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[48;2;36;36;36;38;2;238;238;238m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;2;204;204;204m'
export LESS_TERMCAP_ue=$'\e[0m'
eval "$(starship init bash)"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Run fastfetch on shell initialization
fastfetch

# >>> Codex installer >>>
export PATH="/home/nanda-kumudhan/.local/bin:$PATH"
# <<< Codex installer <<<
