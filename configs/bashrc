# ~/.bashrc: executed by bash(1) for non-login shells.

#GREEN=$'\033[1;32m'
#RED=$'\033[1;31m'
#NONE=$'\033[m'

GREEN="$(tput setaf 2)$(tput bold)"
RED="$(tput setaf 1)$(tput bold)"
NONE=$(tput sgr0)

get_exit_status(){
   es=$?
   if [ $es -eq 0 ]
   then
       echo -e "${GREEN}${es}${NONE}"
   else
       echo -e "${RED}${es}${NONE}"
   fi
}

PROMPT_COMMAND='exitStatus=$(get_exit_status)'
PS1='\n\[${exitStatus}\] ${debian_chroot:+($debian_chroot)}\u@\h:\w\$ \n'

# Note: PS1 and umask are already set in /etc/profile. You should not
# need this unless you want different defaults for root.
# umask 022

# You may uncomment the following lines if you want `ls' to be colorized:
export LS_OPTIONS='--color=auto'
eval "`dircolors`"
alias ls='ls $LS_OPTIONS'
alias ll='ls $LS_OPTIONS -l'
alias l='ls $LS_OPTIONS -lA'

alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

#
# Some more alias to avoid making mistakes:
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

#useful
alias here='nautilus .'

# A shortcut function that simplifies usage of xclip.
# - Accepts input from either stdin (pipe), or params.
# ------------------------------------------------
cb() {
  local _scs_col="\e[0;32m"; local _wrn_col='\e[1;31m'; local _trn_col='\e[0;33m'
  # Check that xclip is installed.
  if ! type xclip > /dev/null 2>&1; then
    echo -e "$_wrn_col""You must have the 'xclip' program installed.\e[0m"
  # Check user is not root (root doesn't have access to user xorg server)
  elif [[ "$USER" == "root" ]]; then
    echo -e "$_wrn_col""Must be regular user (not root) to copy a file to the clipboard.\e[0m"
  else
    # If no tty, data should be available on stdin
    if ! [[ "$( tty )" == /dev/* ]]; then
      input="$(< /dev/stdin)"
    # Else, fetch input from params
    else
      input="$*"
    fi
    if [ -z "$input" ]; then  # If no input, print usage message.
      echo "Copies a string to the clipboard."
      echo "Usage: cb <string>"
      echo "       echo <string> | cb"
    else
      # Copy input to clipboard
      echo -n "$input" | xclip -selection c
      # Truncate text for status
      if [ ${#input} -gt 80 ]; then input="$(echo $input | cut -c1-80)$_trn_col...\e[0m"; fi
      # Print status.
      echo -e "$_scs_col""Copied to clipboard:\e[0m $input"
    fi
  fi
}
# Aliases / functions leveraging the cb() function
# ------------------------------------------------
# Copy contents of a file
function cbf() { cat "$1" | cb; }  
# Copy SSH public key
alias cbssh="cbf ~/.ssh/id_rsa.pub"  
# Copy current working directory
alias cbwd="pwd | cb"  
# Copy most recent command in bash history
alias cbhs="cat $HISTFILE | tail -n 1 | cb"  

