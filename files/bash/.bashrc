## TODO: explain it
## If not running interactively, don't do anything
case $- in
*i*) ;;
*) return ;;
esac

# Bash buildins 
shopt -s checkwinsize           # dynamically update the windows size
                                # Try to disable it and type the following command to see the difference
                                # `while : ; do printf "%s | %s\n" $COLUMNS $(tput cols); sleep 1; done`
# - history
## bash saves each command you typed into memory, and only log them down into history file when bash session closed. 
## the history file is defined by `HISTFILE` variable, by default `HISTFILE=~/.bash_history`.

HISTSIZE=1000                   # the maxium number of lines of history stored in memory
shopt -s histappend             # if hisappend is unset, the history file will be override once in-memory history > HISTSIZE 
HISTFILESIZE=2000               # the maxium number of lines of history file
HISTCONTROL=ignoreboth          # no duplication of history

                                
                                # PROMPT_COMMAND run command before the printing of each primary prompt (PS1)
                                # uncomment it if you like the synchronization of history in multiple terminals
# PROMPT_COMMAND="history -a; history -c; history -r"   

                                # append command into history file once command "Entered"
                                # clear in-memory history
                                # load history file into memory for current session
# - glob
shopt -s nullglob               # disable output a literal `*` for globbing in an empty directory
                                # try to `echo *` in an empty directory, output should return an empty list                                    

shopt -s globstar               # globbing with `**` will match recursively into all folders


# Path
## TODO: explain it
## https://unix.stackexchange.com/questions/14895/duplicate-entries-in-path-a-problem
function addToPATH {
  case ":$PATH:" in
    *":$1:"*) :;; # already there
    *) PATH="$PATH:$1";; # or PATH="$PATH:$1"
  esac
}

addToPATH "$HOME/bin"
addToPATH "$HOME/.local/bin"
addToPATH "/home/linuxbrew/.linuxbrew/bin"

## display path line by line
alias path="echo $PATH | sed 's/:/\n/g'"

# Auto completion 
# - system
if ! shopt -oq posix; then
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi

# - homebrew 
if type brew &>/dev/null; then
  HOMEBREW_PREFIX="$(brew --prefix)"
  if [[ -r "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh" ]]; then
    source "${HOMEBREW_PREFIX}/etc/profile.d/bash_completion.sh"
  else
    for COMPLETION in "${HOMEBREW_PREFIX}/etc/bash_completion.d/"*; do
      [[ -r "$COMPLETION" ]] && source "$COMPLETION"
    done
  fi
fi

# Tmux
# TODO: issue track, ssh session closed causing tmux pane freezed
# when ssh session close because of the accidently interruption of the internet
# the tmux pane will freeze and unable to be closed
alias tmux-list="tmux ls"
alias tmux-kill="tmux kill-session -t $1"
alias tmux-killall="tmux kill-server"
alias tmux-session="tmux new-session -A -s $1"      # `-A` means create or attach to session if existed


# Handy shortcuts and functions
# - change directory 
alias desktop="cd ~/Desktop"
alias dev="cd ~/dev"
alias dotfiles="cd ~/dotfiles"
## reload
alias reb="exec bash"                               # `source ~/.bashrc` will preserve the current shell
                                                    # `exec ~/.bashrc` will replace the current shell with a new instance
                                                    #  and all ad-hoc variables, function ... will lost
# - list
alias l="ls"
alias la="ls -A"
alias ld="ls -dl . .."

# - clear
alias clr="clear"

# - copy
alias pbcopy="xclip -selection c"
copy() { printf "$*" | pbcopy; }                    # copy the string followed by `copy` commands to clipboard

# - delete
alias del="trash"
alias rm="echo Use 'del', or the full path i.e. '/bin/rm'"

# - networking
## show exported ports
alias port="sudo netstat -tulpn"
## test networking spped
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python3 -"
## create hot spot
alias hotspot="sudo create_ap wlp1s0 wlp1s0 MITMing $@"

# - download
## curl
##   -O: use the remote file name
##   -L: follow the http reditect rule
##   -#: display progress bar
download() { curl -OL# "$1"; }
_download_extract() {
    archive="$(basename $1)"
    curl -OL# $1 && 7z x $archive && rm $archive
}
alias download-extract="_download_extract"

# - disk usage
## du
##   -h: human readable
##   -s: summarize, show the sum of sub-directories
##   -c: show grant taotal
## sort
##   -h: compare human readable number
##   -r: sort in reverse order
_ls_size() { du -shc "$@" | sort -rh; }
alias ls-size="_ls_size"

# - gpg
##   -a: output with ASCII format, default output is in binary format
alias gpg-create="gpg --generate-key"
alias gpg-export-public="gpg -a --export"
alias gpg-export-private="gpg -a --export-secret-key"
alias gpg-list="gpg --list-keys"
## enable gpg passphrase prompt for all shell invocations
export GPG_TTY=$(tty)   

# - youtube-dl
_music_dl() {
    youtube-dl -x --audio-quality 0 --audio-format mp3 "$@"
}

_music_list_dl() {
    _music_dl -o '%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s' "$@"
}

alias music-dl="_music_dl"
alias music-list-dl="_music_list_dl"

# Include directory files
## source all scripts in the first layer of ~/.bash.d directory
## scripts are better written independently in prevent of ordering or overwritten issue
if [ -d ~/.bash.d ]; then
    for item in ~/.bash.d/* ; do
        if [ -f "$item" ]; then
            source "$item"
        fi
    done
fi

# Run default tmux session
if [ "$VSCODE_WORKSPACE" = "vscode" ]; then         
    :                                               # for vscode, don't apply tmux-session if you are not in a workspace     
elif [[ "$VSCODE_WORKSPACE" && -z "$TMUX" ]]; then
    tmux-session $VSCODE_WORKSPACE                  # if you are in vscode workspace with `VSCODE_WORKSPACE` variable provided
                                                    # attach or create or a new tmux-session for it
elif [ -z "$TMUX" ]; then
    tmux-session main                               # tmux-session named "main" for my regular terminal environment
fi

