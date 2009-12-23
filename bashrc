# set up some convenient aliases
alias l='ls -lFA'
alias ad='pushd'
alias rd='popd'
alias nd='pushd +1'
alias grep='grep -si'

# set the mysql prompt to the host I am connected to
export MYSQL_PS1="\h> "

# put the name of the current command in the prompt so screen can get it
export PS1="\u@\h \w"'\[\033k\033\\\]\$ '

# add local perl lib
export PERL5LIB=~/lib:$PERL5LIB

export PERSONAL_KEY='iBl5x/zfr2BNAJbFfz/NngA==aslovelyz0ewoiuew78634234etf4v0'

# set vim as my editor
export EDITOR=`which vim`

# add some stuff to my path
export PATH=~/doc/bin:/usr/local/bin:/usr/local/sbin:/usr/local/mysql/bin:/opt/local/bin:/opt/local/sbin:$PATH

# for x11
export DISPLAY=:0.0

# set color on the command line
export CLICOLOR=true

# save more commands in history
export HISTSIZE=5000
export HISTFILESIZE=5000

export HISTCONTROL=ignoreboth
shopt -s histappend

# print the version of a perl module
pmversion () {
	perl -MUNIVERSAL::require -e "$1->require; print \"$1 -> version \" . $1->VERSION . \"\n\""
}

# if keychain exists, set up auth
if type -P keychain &>/dev/null; then
	auth () {
		keychain -q --timeout 480 id_rsa
		[ -f $HOME/.keychain/$HOSTNAME-sh ] && . $HOME/.keychain/$HOSTNAME-sh
	}
	reauth () {
		keychain -k mine
		auth
	}
	auth
fi
