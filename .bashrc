if [ -f "$HOME/.git-prompt.sh" ]; then
	source "$HOME/.git-prompt.sh"
fi

if [ -f "$HOME/.git-completion.bash" ]; then
	source ~/.git-completion.bash
fi

# set the mysql prompt to the host I am connected to
export MYSQL_PS1="\h> "

function __prompt_color() {
	text="$1"
	color=$(($(echo $1 | cksum | cut -c1-3) % 256))
	if [ -n "$text" ]; then
		printf "\[\x1b[38;5;${color}m\]${text}\[\x1b[0m\]";
	fi
}

function __color_branch() {
	text=$(__prompt_color "$(__git_ps1 '%s')")
	if [ -n "$text" ]; then
		echo " ($text)"
	fi
}

COLOR_HOSTNAME=$(__prompt_color $(hostname -s))

function set_prompt() {
#	PS1="\u@\h \w\$ "
	PS1="\u@$COLOR_HOSTNAME \w$(__color_branch)\$ "
}

# set vim as my editor
export EDITOR=`which vim`

# add some stuff to my path
export PATH=~/bin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:/opt/local/sbin:$PATH

export GOPATH=$HOME/go
export GOROOT=/usr/local/opt/go/libexec
export PATH=$PATH:$GOPATH/bin

# for x11
export DISPLAY=:0.0

# set color on the command line
export CLICOLOR=true

# save more commands in history
export HISTSIZE=1000000
export HISTFILESIZE=1000000

# don't store duplicate commands in bash history
export HISTCONTROL=ignoreboth

# append bash history after every command (so multiple terminals share the same history)
shopt -s histappend
export PROMPT_COMMAND="history -a; set_prompt; $PROMPT_COMMAND"

# multi-line commands should be stored as a single command
shopt -s cmdhist

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
