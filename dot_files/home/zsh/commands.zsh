autoload -Uz zargs
compdef _precommand rg
compdef _precommand nse
compdef _precommand an

zman() {
  cman $1 zshall
}

autoload -Uz tetris

# mess -- switch to current mess folder, creating it if needed
# 17may2008  +chris+
mess() {
  set +e
  DIR=~/mess/$(date +%Y/%V)
  [[ -d $DIR ]] || {
  mkdir -p $DIR
  ln -sfn $DIR ~/mess/current
  echo "Created $DIR."
}
cd ~/mess/current
}
hash -d mess=~/mess/current

#complete from tmux buffer
_tmux_pane_words() {
  local expl
  local -a w
  if [[ -z "$TMUX_PANE" ]]; then
    _message "not running inside tmux!"
    return 1
  fi
  w=( ${(u)=$(tmux capture-pane \; show-buffer \; delete-buffer)} )
  _wanted values expl 'words from current tmux pane' compadd -a w
}

zle -C tmux-pane-words-prefix   complete-word _generic
#zle -C tmux-pane-words-anywhere complete-word _generic
bindkey '^XS' tmux-pane-words-prefix
#bindkey '^Xt' tmux-pane-words-prefix
#TODO: pointless with complete inword? ( 21-Feb-2013, John Doe )
#bindkey '^X^X' tmux-pane-words-anywhere
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' completer _tmux_pane_words
zstyle ':completion:tmux-pane-words-(prefix|anywhere):*' ignore-line current
#zstyle ':completion:tmux-pane-words-anywhere:*' matcher-list 'b:=* m:{A-Za-z}={a-zA-Z}'



move() {
  emulate  -L  zsh
  local src=$1 dst=$2
  if [ -d $src ]; then
    if [ -d $dst ]; then
      src=${src%/}
    else
      src=${src%/}/
    fi
  fi
  rsync -Pha --remove-source-files $src $dst
  [ -d $src ] && rmdir $src/**/*(od) $src
}



# hooks

load_hooks() {
  autoload -Uz add-zsh-hook

  function -set-tab-and-window-title() {
    emulate -L zsh
    local CMD="${1:gs/$/\\$}"
    print -Pn "\e]0;$CMD:q\a"
    if [ -n "$TMUX" ]; then
      print -Pn "\ek$CMD\e\\"
    fi
  }

  # $HISTCMD (the current history event number) is shared across all shells
  # (due to SHARE_HISTORY). Maintain this local variable to count the number of
  # commands run in this specific shell.
  HISTCMD_LOCAL=0

  # Executed before displaying prompt.
  function -update-window-title-precmd() {
    emulate -L zsh
    local msg
    if [[ $TERM == screen* ]] || [[ $TERM == tmux* ]]; then
      if [[ -n ${vcs_info_msg_1_} ]] ; then
        msg=${vcs_info_msg_1_}
      else
        msg=zsh
      fi
    fi
    #if [ -n "$TMUX" ]; then
      # Inside tmux, just show the last command: tmux will prefix it with the
      # session name (for context).
      -set-tab-and-window-title "$msg"
    #else
      # Outside tmux, show $PWD (for context) followed by the last command.
      -set-tab-and-window-title "$(basename $PWD) > $msg"
    #fi
  }
  add-zsh-hook precmd -update-window-title-precmd

  # Executed before executing a command: $2 is one-line (truncated) version of
  # the command.
  function -update-window-title-preexec() {
    emulate -L zsh
    setopt EXTENDED_GLOB
    HISTCMD_LOCAL=$((++HISTCMD_LOCAL))

    # Skip ENV=settings, sudo, ssh; show first distinctive word of command;
    # mostly stolen from:
    #   https://github.com/robbyrussell/oh-my-zsh/blob/master/lib/termsupport.zsh
    local TRIMMED="${2[(wr)^(*=*|mosh|ssh|sudo|an|nse|-*)]}"
    #if [ -n "$TMUX" ]; then
      # Inside tmux, show the running command: tmux will prefix it with the
      # session name (for context).
      -set-tab-and-window-title "$TRIMMED"
    #else
      # Outside tmux, show $PWD (for context) followed by the running command.
      -set-tab-and-window-title "$(basename $PWD) > $TRIMMED"
    #fi
  }
  add-zsh-hook preexec -update-window-title-preexec

  typeset -F SECONDS
  function -record-start-time() {
    emulate -L zsh
    ZSH_START_TIME=${ZSH_START_TIME:-$SECONDS}
  }
  add-zsh-hook preexec -record-start-time

  function -report-start-time() {
    emulate -L zsh
    if [ $ZSH_START_TIME ]; then
      local DELTA=$(($SECONDS - $ZSH_START_TIME))
      local DAYS=$((~~($DELTA / 86400)))
      local HOURS=$((~~(($DELTA - $DAYS * 86400) / 3600)))
      local MINUTES=$((~~(($DELTA - $DAYS * 86400 - $HOURS * 3600) / 60)))
      local SECS=$(($DELTA - $DAYS * 86400 - $HOURS * 3600 - $MINUTES * 60))
      local ELAPSED=''
      test "$DAYS" != '0' && ELAPSED="${DAYS}d"
      test "$HOURS" != '0' && ELAPSED="${ELAPSED}${HOURS}h"
      test "$MINUTES" != '0' && ELAPSED="${ELAPSED}${MINUTES}m"
      if [ "$ELAPSED" = '' ]; then
        SECS="$(print -f "%.2f" $SECS)s"
      elif [ "$DAYS" != '0' ]; then
        SECS=''
      else
        SECS="$((~~$SECS))s"
      fi
      ELAPSED="${ELAPSED}${SECS}"
      export RPROMPT="%F{cyan}%{$__WINCENT[ITALIC_ON]%}${ELAPSED}%{$__WINCENT[ITALIC_OFF]%}%f $RPROMPT_BASE"
      unset ZSH_START_TIME
    else
      export RPROMPT="$RPROMPT_BASE"
    fi
  }
  add-zsh-hook precmd -report-start-time

  #add-zsh-hook precmd bounce

  function -auto-ls-after-cd() {
    emulate -L zsh
    # Only in response to a user-initiated `cd`, not indirectly (eg. via another
    # function).
    if [ "$ZSH_EVAL_CONTEXT" = "toplevel:shfunc" ]; then
      ls -a
    fi
  }
  add-zsh-hook chpwd -auto-ls-after-cd

  # Remember each command we run.
  function -record-command() {
    __WINCENT[LAST_COMMAND]="$2"
  }
  add-zsh-hook preexec -record-command

  # Update vcs_info (slow) after any command that probably changed it.
  function -maybe-show-vcs-info() {
    local LAST="$__WINCENT[LAST_COMMAND]"

    # In case user just hit enter, overwrite LAST_COMMAND, because preexec
    # won't run and it will otherwise linger.
    __WINCENT[LAST_COMMAND]="<unset>"

    # Check first word; via:
    # http://tim.vanwerkhoven.org/post/2012/10/28/ZSH/Bash-string-manipulation
    case "$LAST[(w)1]" in
      cd|cp|git|rm|touch|mv)
        vcs_info
        ;;
      *)
        ;;
    esac
  }
  add-zsh-hook precmd -maybe-show-vcs-info
}
if [ "$TERM" != linux ]; then
  load_hooks
fi

# adds `cdr` command for navigating to recent directories
autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
add-zsh-hook chpwd chpwd_recent_dirs

# enable menu-style completion for cdr
zstyle ':completion:*:*:cdr:*:*' menu selection

# fall through to cd if cdr is passed a non-recent dir as an argument
zstyle ':chpwd:*' recent-dirs-default true
