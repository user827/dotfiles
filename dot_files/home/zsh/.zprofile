# A new terminal should start a login shell

[ ! -f $HOME/.profile ] || source $HOME/.profile
[ ! -f $HOME/.zprofile.local.zsh ] || source $HOME/.zprofile.local.zsh
