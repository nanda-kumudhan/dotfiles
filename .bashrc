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
PS1='\[\e[38;2;122;162;227m\]\W\[\e[38;2;143;191;127m\] \$\[\e[0m\] '
# Directories are colored, not bold; reserve bold for executables and warnings.
export LS_COLORS='di=38;2;122;162;227:ln=38;2;111;183;200:ex=1;38;2;143;191;127:bd=38;2;201;164;95:cd=38;2;201;164;95:su=1;38;2;215;111;123:sg=1;38;2;215;111;123:tw=38;2;181;139;220:ow=38;2;181;139;220:*.tar=38;2;201;164;95:*.tgz=38;2;201;164;95:*.zip=38;2;201;164;95:*.gz=38;2;201;164;95:*.xz=38;2;201;164;95:*.7z=38;2;201;164;95:*.jpg=38;2;181;139;220:*.jpeg=38;2;181;139;220:*.png=38;2;181;139;220:*.gif=38;2;181;139;220:*.webp=38;2;181;139;220:*.mp4=38;2;111;183;200:*.mkv=38;2;111;183;200:*.mp3=38;2;111;183;200:*.flac=38;2;111;183;200:*.rs=38;2;214;180;106:*.py=38;2;214;180;106:*.js=38;2;214;180;106:*.ts=38;2;214;180;106:*.go=38;2;214;180;106:*.c=38;2;214;180;106:*.cpp=38;2;214;180;106:*.java=38;2;214;180;106:*.rb=38;2;214;180;106:*.sh=38;2;214;180;106'
export GREP_COLORS='ms=01;38;2;215;111;123:mc=01;38;2;215;111;123:sl=:cx=:fn=38;2;122;162;227:ln=38;2;86;97;111:bn=38;2;86;97;111:se=38;2;86;97;111'
export LESS_TERMCAP_md=$'\e[1;38;2;216;222;233m'
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_so=$'\e[48;2;38;50;65;38;2;216;222;233m'
export LESS_TERMCAP_se=$'\e[0m'
export LESS_TERMCAP_us=$'\e[4;38;2;111;183;200m'
export LESS_TERMCAP_ue=$'\e[0m'
eval "$(starship init bash)"
export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/ssh-agent.socket"

# Run fastfetch on shell initialization
fastfetch

# >>> Codex installer >>>
export PATH="/home/nanda-kumudhan/.local/bin:$PATH"
# <<< Codex installer <<<
