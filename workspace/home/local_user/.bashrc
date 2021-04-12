# reads
# https://sunlightmedia.org/bash-vs-zsh/
# https://www.addictivetips.com/mac-os/hide-default-interactive-shell-is-now-zsh-in-terminal-on-macos/
# https://geoff.greer.fm/lscolors/
# bash shortcuts - https://natelandau.com/my-mac-osx-bash_profile/

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# Build a list with all servers to use for autocomplete with SSH and SCP
# make sure the ssh config property 'HashKnownHosts' is set to 'no'
HOSTLIST=$(echo `cat ~/.ssh/known_hosts | cut -f 1 -d ' ' | sed -e s/,.*//g | sed -e 's/^\[\(.*\)\].*/\1/g' | egrep -v '^[0-9]' | uniq`;)
complete -o bashdefault -o default -W "${HOSTLIST}" ssh
complete -o bashdefault -o default -o nospace -W "${HOSTLIST}" scp

# Add `~/.bin` to the `$PATH`
export PATH="$HOME/.bin:/usr/local/sbin:/usr/local/bin:$PATH";

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
shopt -s globstar

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    alias dir='dir --color=auto'
    alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# project alias definitions.
source ~/.bash_aliases

# load NPM auto completion
source ~/.bash_npm_completion

# https://github.com/git/git/tree/master/contrib/completion
# load GIT auto completion and prompt
source /usr/share/bash-completion/completions/git
source /etc/bash_completion.d/git-prompt

# Show dirty state in git prompt
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_DISCOVERY_ACROSS_FILESYSTEM=1

# set colored prompt
PS1="\[\033[1;30m\][\033[0;32m\]\t - \033[0;31m\]\u\033[1;37m\]\[\033[1;37m\]@\[\033[1;33m\]\h\[\033[1;30m\]] \[\033[0;37m\]\W\[\033[1;30m\]\[\033[0m\]\[$MAGENTA\]\$(__git_ps1)\[$WHITE\] \$ "

# load the ssh-agent when the user logs in.
# if an ssh-agent is forwarded than that one will be used.
# all keys are imported and if needed the user will be prompted for a password.
ssh-add -l &>/dev/null
if [ "$?" == 2 ]; then
    test -r ~/.ssh/.ssh_agent && eval "$(<~/.ssh/.ssh_agent)" >/dev/null
    ssh-add -l &>/dev/null

    if [ "$?" == 2 ]; then

        (umask 066; ssh-agent > ~/.ssh/.ssh_agent)
        eval "$(<~/.ssh/.ssh_agent)" >/dev/null
        ssh-add
    fi
fi

# Set default editor
EDITOR=vim;

# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# colored listing of diretory content
export CLICOLOR=YES
export LSCOLORS="exfxfxfxcxfxxhAhAhAhAh"

# GO PATH vars
export GOROOT=/usr/local/go
# (~/go is the default since Go 1.8)
export GOPATH=/home/admin/go
# (GOBIN defaults to the bin directory under $GOPATH - so urgent need to set it manually, but we'll set it regardless)
export GOBIN=/home/admin/go/bin

# Redirect to var/www/sites since it is the webroot.
cd /var/www/sites

# want custom bashrc stuff? use ~/.bash_custom_aliases
if [ -f ~/.bash_custom_aliases ]; then
    source ~/.bash_custom_aliases
fi

export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# it's a bit much to do this every shell start
# but for now this is still the best way to go about this
sudo update-ca-certificates > /dev/null 2>&1
