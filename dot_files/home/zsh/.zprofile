# A new terminal should start a login shell

eval $(dircolors -b)

if [[ $TERM == *-256color ]] && [[ -z $TMUX ]] && [[ -z $SCREEN ]]; then
  echo "Setting solarized dark base16 256colors"
  source ${ZDOTDIR:-${HOME}}/data/base16-shell/scripts/base16-solarized-dark.sh
fi

[ ! -f $HOME/.profile ] || source $HOME/.profile
[ ! -f $HOME/.zprofile.local.zsh ] || source $HOME/.zprofile.local.zsh
