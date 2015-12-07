# set the mysql prompt to the host I am connected to
export MYSQL_PS1="\h> "

# put the name of the current command in the prompt so screen can get it
#export PS1="\u@\h \w"'\[\033k\033\\\]\$ '
export PS1="\u@\\033[38;5;$((($(hostname | cksum | cut -c1-3) + 200) % 256))m\h\\033[0m \w\$ "

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
export HISTSIZE=5000
export HISTFILESIZE=5000

# don't store duplicate commands in bash history
export HISTCONTROL=ignoreboth

# append bash history after every command (so multiple terminals share the same history)
shopt -s histappend
export PROMPT_COMMAND='history -a'

# multi-line commands should be stored as a single command
shopt -s cmdhist

export NVM_DIR="/Users/travis/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
