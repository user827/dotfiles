case "$(tty)" in
  # Logout terminal after 600 seconds
  /dev/tty[0-9]*)
    TMOUT=600
    #[[ $- = *l* ]] && return
    alias startx='exec myx'
    alias myway='exec sh myway'

    ;;
esac

if [[ -n "$DISPLAY" ]]; then
  alias sudo="sudo -A"
fi

# Setopts {{{{

# history
#v#
HISTFILE=${ZDOTDIR:-${HOME}}/.zsh_history
HISTSIZE=15000 # should be larger than savehist for trimming dups
SAVEHIST=10000 # useful for setopt append_history

TIMEFMT="%J  %U user %S system %P cpu %MM memory %*E total"

# set some important options (as early as possible)

# append history list to the history file; this is the default but we make sure
# because it's required for share_history.
setopt append_history

# import new commands from the history file also in other zsh-session
# me likes own history for each window
unsetopt share_history

# save each command's beginning timestamp and the duration to the history file
setopt extended_history

# If a new command line being added to the history list duplicates an older
# one, the older command is removed from the list
setopt histignorealldups
# setopt hist_expire_dups_first
# I want to know what the order of commands was before too
# ... but this causes the history to loose important entries too soon?
# setopt HIST_IGNORE_DUPS


# remove command lines from the history list when the first character on the
# line is a space
setopt histignorespace

# if a command is issued that can't be executed as a normal command, and the
# command is the name of a directory, perform the cd command to that directory.
unsetopt auto_cd

# in order to use #, ~ and ^ for filename generation grep word
# *~(*.gz|*.bz|*.bz2|*.zip|*.Z) -> searches for word not in compressed files
# don't forget to quote '^', '~' and '#'!
# NOTE required by this script
setopt extendedglob

# display PID when suspending processes as well
setopt longlistjobs

# report the status of backgrounds jobs immediately
setopt notify

# whenever a command completion is attempted, make sure the entire command path
# is hashed first.
setopt hash_list_all

# not just at the end
setopt completeinword

# Don't send SIGHUP to background processes when the shell exits.
unsetopt nohup

# make cd push the old directory onto the directory stack.
setopt auto_pushd

# avoid "beep"ing
setopt nobeep

# don't push the same dir twice.
setopt pushd_ignore_dups

# * shouldn't match dotfiles. ever.
setopt noglobdots

# use zsh style word splitting
setopt noshwordsplit

# don't error out when unset parameters are used
setopt unset

unsetopt clobber
setopt correct
setopt list_packed
setopt glob_complete # use PATTERN matching for the pattern instead of globbing #USE zstyle expand
#setopt NO_ALWAYS_LAST_PROMPT
#make the list and menu appear sooner! Makes up for menu_complete
unsetopt list_ambiguous
unsetopt list_beep
setopt inc_append_history
unsetopt cdable_vars
#unhash -f chpwd #Disable grml auto stack
unsetopt flow_control
# since prezto
unsetopt rc_quotes
setopt promptsubst
setopt transientrprompt

setopt interactivecomments


# report about cpu-/system-/user-time of command if running longer than
# 5 seconds
#REPORTTIME=5

# watch for everyone but me and root
watch=(notme root)

# automatically remove duplicates from these arrays
typeset -U path cdpath fpath manpath

# }}}}

# Load a few modules {{{{
for mod in parameter complist deltochar mathfunc ; do
    zmodload -i zsh/${mod} 2>/dev/null || print "Notice: no ${mod} available :("
done && builtin unset -v mod

# autoload zsh modules when they are referenced
zmodload -a  zsh/stat    zstat
zmodload -a  zsh/zpty    zpty
zmodload -ap zsh/mapfile mapfile


autoload -Uz zmv
autoload -Uz zed

# NOTE: must come before zsh-history-substring-search & zsh-syntax-highlighting.
autoload -Uz select-word-style
# do this afte zsh-syntax higihlight if you do not want to override default widgets...
select-word-style shell

source ${ZDOTDIR:-${HOME}}/data/zsh-autosuggestions/zsh-autosuggestions.zsh
if [ "$TERM" != linux ]; then
  :
  #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=59'
else
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=1'
  #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=5'
  #ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=4'
fi
# TODO some bindkeys ignored because we call bindkey -e later

#source ${ZDOTDIR:-${HOME}}/zsh-history-substring-search/zsh-history-substring-search.zsh
#HISTORY_SUBSTRING_SEARCH_ENSURE_UNIQUE=1

ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets)
source ${ZDOTDIR:-${HOME}}/data/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# }}}}

# {{{{ Completion system
COMPDUMPFILE=${COMPDUMPFILE:-${ZDOTDIR:-${HOME}}/.zcompdump}
autoload -Uz compinit
compinit -d ${COMPDUMPFILE} || print 'Notice: no compinit available :('


# allow one error for every three characters typed in approximate completer
zstyle ':completion:*:approximate:'    max-errors 'reply=( $((($#PREFIX+$#SUFFIX)/3 )) numeric )'

# don't complete backup files as executables
zstyle ':completion:*:complete:-command-::commands' ignored-patterns '(aptitude-*|*\~)'

# start menu completion only if it could find no unambiguous initial string
zstyle ':completion:*:correct:*'       insert-unambiguous true
zstyle ':completion:*:corrections'     format $'%{\e[0;31m%}%d (errors: %e)%{\e[0m%}'
zstyle ':completion:*:correct:*'       original true

# activate color-completion
zstyle ':completion:*:default'         list-colors ''

# format on completion
zstyle ':completion:*:descriptions'    format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'

# automatically complete 'cd -<tab>' and 'cd -<ctrl-d>' with menu
# zstyle ':completion:*:*:cd:*:directory-stack' menu yes select

# insert all expansions for expand completer
zstyle ':completion:*:expand:*'        tag-order all-expansions
zstyle ':completion:*:history-words'   list false

# activate menu
zstyle ':completion:*:history-words'   menu yes

# ignore duplicate entries
zstyle ':completion:*:history-words'   remove-all-dups yes
zstyle ':completion:*:history-words'   stop yes

# match uppercase from lowercase
zstyle ':completion:*'                 matcher-list 'm:{a-z}={A-Z}'

# separate matches into groups
zstyle ':completion:*:matches'         group 'yes'
zstyle ':completion:*'                 group-name ''

# if there are more than 5 options allow selecting from a menu
zstyle ':completion:*'                 menu select=5

zstyle ':completion:*:messages'        format '%d'
zstyle ':completion:*:options'         auto-description '%d'

# describe options in full
zstyle ':completion:*:options'         description 'yes'

# on processes completion complete all user processes
zstyle ':completion:*:processes'       command 'ps -au$USER'

# offer indexes before parameters in subscripts
zstyle ':completion:*:*:-subscript-:*' tag-order indexes parameters

# provide verbose completion information
zstyle ':completion:*'                 verbose true

# recent (as of Dec 2007) zsh versions are able to provide descriptions
# for commands (read: 1st word in the line) that it will list for the user
# to choose from. The following disables that, because it's not exactly fast.
zstyle ':completion:*:-command-:*:'    verbose false

# set format for warnings
zstyle ':completion:*:warnings'        format $'%{\e[0;31m%}No matches for:%{\e[0m%} %d'

# define files to ignore for zcompile
zstyle ':completion:*:*:zcompile:*'    ignored-patterns '(*~|*.zwc)'
zstyle ':completion:correct:'          prompt 'correct to: %e'

# Ignore completion functions for commands you don't have:
zstyle ':completion::(^approximate*):*:functions' ignored-patterns '_*'

# Provide more processes in completion of programs like killall:
zstyle ':completion:*:processes-names' command 'ps c -u ${USER} -o command | uniq'

# complete manual by their section
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# Search path for sudo completion
zstyle ':completion:*:sudo:*' command-path /usr/local/sbin \
                                           /usr/local/bin  \
                                           /usr/sbin       \
                                           /usr/bin        \
                                           /sbin           \
                                           /bin            \
                                           /usr/X11R6/bin

# provide .. as a completion
zstyle ':completion:*' special-dirs ..

# run rehash on completion so new installed program are found automatically:
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1
}

## correction
# try to be smart about when to use what completer...
# # NOTE overridded in .zshrd for working with fasd
#BUG _oldlist should always be first, or otherwise menu complete may fail to start after a part has been added
#Still buggy as cannot partial add to completion or it fails; add _expand too for better matches-list below
#expand fails when trying for full word?? does work too
zstyle -e ':completion:*' completer '
    if [[ $_last_try != "$HISTNO$BUFFER$CURSOR" ]] ; then
        _last_try="$HISTNO$BUFFER$CURSOR"
        reply=(_oldlist _expand _complete _match _ignored _prefix _files)
    else
        if [[ $words[1] == (rm|mv) ]] ; then
            reply=(_complete _files)
        else
            reply=(_oldlist _expand _force_rehash _complete _ignored _correct _approximate _files)
        fi
    fi'

# command for process lists, the local web server details and host completion
zstyle ':completion:*:urls' local 'www' '/var/www/' 'public_html'

# Some functions, like _apt and _dpkg, are very slow. We can use a cache in
# order to speed things up
if [[ ${GRML_COMP_CACHING:-yes} == yes ]]; then
    GRML_COMP_CACHE_DIR=${GRML_COMP_CACHE_DIR:-${ZDOTDIR:-$HOME}/.cache}
    if [[ ! -d ${GRML_COMP_CACHE_DIR} ]]; then
        command mkdir -p "${GRML_COMP_CACHE_DIR}"
    fi
    zstyle ':completion:*' use-cache  yes
    zstyle ':completion:*:complete:*' cache-path "${GRML_COMP_CACHE_DIR}"
fi


# host completion
[[ -r ~/.ssh/config ]] && _ssh_config_hosts=(${${(s: :)${(ps:\t:)${${(@M)${(f)"$(<$HOME/.ssh/config)"}:#Host *}#Host }}}:#*[*?]*}) || _ssh_config_hosts=()
[[ -r ~/.ssh/known_hosts ]] && _ssh_hosts=(${${${${(f)"$(<$HOME/.ssh/known_hosts)"}:#[\|]*}%%\ *}%%,*}) || _ssh_hosts=()
[[ -r /etc/hosts ]] && : ${(A)_etc_hosts:=${(s: :)${(ps:\t:)${${(f)~~"$(</etc/hosts)"}%%\#*}##[:blank:]#[^[:blank:]]#}}} || _etc_hosts=()
hosts=(
    $(uname -n)
    "$_ssh_config_hosts[@]"
    "$_ssh_hosts[@]"
    "$_etc_hosts[@]"
    localhost
)
zstyle ':completion:*:hosts' hosts $hosts
# TODO: so, why is this here?
#  zstyle '*' hosts $hosts

# see upgrade function in this file
compdef _hosts upgrade
# }}}}

# Prompt {{{{
typeset -A __WINCENT

__WINCENT[ITALIC_ON]=$'\e[3m'
__WINCENT[ITALIC_OFF]=$'\e[23m'

load_prompt() {
  # from wincent
  autoload -U colors
  colors

  # http://zsh.sourceforge.net/Doc/Release/User-Contributions.html
  autoload -Uz vcs_info
  zstyle ':vcs_info:*' enable git hg
  zstyle ':vcs_info:*' check-for-changes true
  zstyle ':vcs_info:*' disable-patterns "${(b)HOME}/code/(portal|portal-ee|portal-master)(|/*)"
  zstyle ':vcs_info:*' stagedstr "%F{green}●%f" # default 'S'
  zstyle ':vcs_info:*' unstagedstr "%F{red}●%f" # default 'U'
  zstyle ':vcs_info:*' use-simple true
  zstyle ':vcs_info:git+set-message:*' hooks git-untracked
  zstyle ':vcs_info:git*:*' formats '[%b%m%c%u] ' # default ' (%s)-[%b]%c%u-'
  zstyle ':vcs_info:git*:*' actionformats '[%b|%a%m%c%u] ' # default ' (%s)-[%b|%a]%c%u-'
  zstyle ':vcs_info:hg*:*' formats '[%m%b] '
  zstyle ':vcs_info:hg*:*' actionformats '[%b|%a%m] '
  zstyle ':vcs_info:hg*:*' branchformat '%b'
  zstyle ':vcs_info:hg*:*' get-bookmarks true
  zstyle ':vcs_info:hg*:*' get-revision true
  zstyle ':vcs_info:hg*:*' get-mq false
  zstyle ':vcs_info:hg*+gen-hg-bookmark-string:*' hooks hg-bookmarks
  zstyle ':vcs_info:hg*+set-message:*' hooks hg-message

  function +vi-hg-bookmarks() {
    emulate -L zsh
    if [[ -n "${hook_com[hg-active-bookmark]}" ]]; then
      hook_com[hg-bookmark-string]="${(Mj:,:)@}"
      ret=1
    fi
  }

  function +vi-hg-message() {
    emulate -L zsh

    # Suppress hg branch display if we can display a bookmark instead.
    if [[ -n "${hook_com[misc]}" ]]; then
      hook_com[branch]=''
    fi
    return 0
  }

  function +vi-git-untracked() {
    emulate -L zsh
    if [[ -n $(git ls-files --exclude-standard --others 2> /dev/null) ]]; then
      hook_com[unstaged]+="%F{blue}●%f"
    fi
  }

  RPROMPT_BASE="\${vcs_info_msg_0_}%F{blue}%f"
  setopt PROMPT_SUBST

  # Anonymous function to avoid leaking variables.
  function () {
    # Check for tmux by looking at $TERM, because $TMUX won't be propagated to any
    # nested sudo shells but $TERM will.
    local TMUXING=$([[ "$TERM" =~ "tmux" ]] && echo tmux)
    if [ -n "$TMUXING" -a -n "$TMUX" ]; then
      # In a a tmux session created in a non-root or root shell.
      local LVL=$(($SHLVL - 1))
    else
      # Either in a root shell created inside a non-root tmux session,
      # or not in a tmux session.
      local LVL=$SHLVL
    fi
    if [[ $EUID -ne 0 ]]; then
      if [[ -n $SUDO_USER ]]; then
        local SUFFIX='%F{yellow}%n%f '$(printf '\u276f%.0s%%f' {1..$LVL})
      else
        local SUFFIX='%f'$(printf '\u276f%.0s%%f' {1..$LVL})
      fi
    else
      local SUFFIX=$(printf '%%%%%%F{red}%.0s%%f' {1..$LVL})
    fi
    export PS1="%F{green}${SSH_TTY:+%n@%m}%f%B${SSH_TTY:+:}%b%F{blue}%B%~%b%F{yellow}%B%(1j.*.)%(?..!)%b%f %B${SUFFIX}%b "
    if [[ -n "$TMUXING" ]]; then
      # Outside tmux, ZLE_RPROMPT_INDENT ends up eating the space after PS1, and
      # prompt still gets corrupted even if we add an extra space to compensate.
      export ZLE_RPROMPT_INDENT=0
    fi
  }

  export RPROMPT=$RPROMPT_BASE
  export SPROMPT="zsh: correct %F{red}'%R'%f to %F{red}'%r'%f [%B%Uy%u%bes, %B%Un%u%bo, %B%Ue%u%bdit, %B%Ua%u%bbort]? "
}

if [ "$TERM" != linux ]; then
  load_prompt
fi

# }}}}

# Aliases {{{{
_myfastnotes() {
  [ -d ~/.quickies ] || mkdir ~/.quickies
  local zedtmp=$(mktemp -p ~/.quickies quicky.XXXXXXXXXX.md)
  #vim -u NONE +star $zedtmp
  vim +star $zedtmp
  if [ -s $zedtmp ]; then
    echo $zedtmp.old.md
    mv $zedtmp $zedtmp.old.md
    find ~/.quickies -type f -name 'quicky.*.old.md' -mtime +1 -delete -printf 'rm: %p\n'
  else
    echo $zedtmp
    rm $zedtmp
  fi
}
# for making notes. fast.
#alias c='_myfastnotes'

alias ls="ls --color=auto"
alias k="an kubectl"


alias gdb='gdb --quiet'
alias info='info --vi-keys'
alias rm='rm -I'
alias mv='mv -i'
alias cp='cp -i'

if type batman > /dev/null; then
  alias man=batman
  compdef _man batman
fi

# https://unix.stackexchange.com/questions/496379/treat-command-like-another-for-completion-purposes
compdefas () {
  if (($+_comps[$1])); then
    compdef $_comps[$1] ${^@[2,-1]}=$1
  fi
}
compdefas pacman pacmatic

# better than rm -f for removing write protected files: tells when target does not
# exist
# unsafe!
#alias Rm='rm -r --interactive=never'

fin() {
  emulate  -L  zsh
  find -iname "*$**"
}

# use commands so the history is saved for easy typing
zl () {
  emulate  -L  zsh
  local olddir=$PWD
  cd ~$1
  # [[ $PWD != $olddir ]] && Lpreview_dir
  [[ $PWD != $olddir ]] && ls -ltcrh
}
#TODO
_zm () {
  emulate  -L  zsh
  local olddir=$PWD
  z $BUFFER
  BUFFER=
  zle reset-prompt
  [[ $PWD != $olddir ]] && zle menu-complete
}
zle -N zm _zm
#bindkey '^[t' zm

# hard names with videos
compdef _precommand v #todo
#compdef _mplayer m #todo
#
#todo seed here?
#abk[rand]="(oe:'REPLY=\$RANDOM':)"



# smart cd function, allows switching to /etc when running 'cd /etc/fstab'
cd() {
    if (( ${#argv} == 1 )) && [[ -f ${1} ]]; then
        [[ ! -e ${1:h} ]] && return 1
        print "Correcting ${1} to ${1:h}"
        builtin cd ${1:h}
    else
        builtin cd "$@"
    fi
}

#f5# Create directory under cursor or the selected area
inplaceMkDirs() {
    # Press ctrl-xM to create the directory under the cursor or the selected area.
    # To select an area press ctrl-@ or ctrl-space and use the cursor.
    # Use case: you type "mv abc ~/testa/testb/testc/" and remember that the
    # directory does not exist yet -> press ctrl-XM and problem solved
    local PATHTOMKDIR
    if ((REGION_ACTIVE==1)); then
        local F=$MARK T=$CURSOR
        if [[ $F -gt $T ]]; then
            F=${CURSOR}
            T=${MARK}
        fi
        # get marked area from buffer and eliminate whitespace
        PATHTOMKDIR=${BUFFER[F+1,T]%%[[:space:]]##}
        PATHTOMKDIR=${PATHTOMKDIR##[[:space:]]##}
    else
        local bufwords iword
        bufwords=(${(z)LBUFFER})
        iword=${#bufwords}
        bufwords=(${(z)BUFFER})
        PATHTOMKDIR="${(Q)bufwords[iword]}"
    fi
    [[ -z "${PATHTOMKDIR}" ]] && return 1
    PATHTOMKDIR=${~PATHTOMKDIR}
    if [[ -e "${PATHTOMKDIR}" ]]; then
        zle -M " path already exists, doing nothing"
    else
        zle -M "$(mkdir -p -v "${PATHTOMKDIR}")"
        zle end-of-line
    fi
}

zle -N inplaceMkDirs


# Basic directory operations
#alias ...='cd ../..' #grml default
#WARNING used for shell builtin
#alias -- -='cd -'
alias -- --='cd -'
# }}}}

# Bindings {{{{

# default bindings
bindkey -e


# uses global ignore file
FZF_CTRL_T_COMMAND='command fd --hidden .'
#FZF_CTRL_T_COMMAND='command fd --hidden --follow --exclude ".git" .'
FZF_ALT_C_COMMAND='command fd --type d --hidden .'
#FZF_ALT_C_COMMAND='command fd --type d --hidden --follow --exclude ".git" .'
# after bindkey
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/key-bindings.zsh
fi
if [ -f /usr/share/fzf/key-bindings.zsh ]; then
  source /usr/share/fzf/completion.zsh
fi

_fzf_compgen_path() {
  fd --hidden "$1"
}

# Use fd to generate the list for directory completion
_fzf_compgen_dir() {
  fd --type d "$1"
}

FZF_ALT_C_OPTS="--preview='test -n \"{}\" && ls {}'"
#my-fzf-cd-widget() {
#  fzf-cd-widget
#}
#zle     -N    my-fzf-cd-widget
#bindkey '\ec' my-fzf-cd-widget
# Use fd to generate the list for directory completion





#bindkey '^[[A' history-substring-search-up
#bindkey '^[[B' history-substring-search-down
#bindkey '^P' history-substring-search-up
#bindkey '^N' history-substring-search-down
#bindkey "^p" history-beginning-search-backward-end
#bindkey "^n" history-beginning-search-forward-end
#bindkey -M vicmd 'k' history-substring-search-up
#bindkey -M vicmd 'j' history-substring-search-down

#autoload -Uz select-word-style
# Do this before loading syntax highlighter
#select-word-style shell
# Use emacs-like key bindings by default:

# use the new *-pattern-* widgets for incremental history search
# better than fzf when searching for exact matches
# ... and for finding latest commands
bindkey '^r' history-incremental-pattern-search-backward
#bindkey '^p' fzf-history-widget
bindkey '^s' history-incremental-pattern-search-forward


autoload -U edit-command-line
zle -N edit-command-line
bindkey '^x^x' edit-command-line

#k# mkdir -p <dir> from string under cursor or marked area
bindkey '^xM' inplaceMkDirs

zle -A backward-kill-word slash-backward-kill-word
# for select-word-style
zstyle ':zle:slash-backward-kill-word' word-style unspecified
zstyle ':zle:slash-backward-kill-word' word-chars /
#k# Kill left-side word or everything up to next slash
bindkey '\ev' slash-backward-kill-word

#autoload -Uz backward-kill-word-match
#zle -N backward-kill-word-match
#bindkey '\ew' backward-kill-word-match
zle -A backward-kill-word backward-kill-word-normal
zstyle ':zle:backward-kill-word-normal' word-style default
bindkey '\ew' backward-kill-word-normal


#interactive menu; dmenu KILLER!
zle -C Linter-menu menu-complete _generic
#TODO use more general definition as basis
zstyle ':completion:Linter-menu:*' menu select interactive
bindkey '^[r' Linter-menu

zle -C Lmodi-menu menu-complete _generic
#TODO use more general definition as basis
zstyle ':completion:Lmodi-menu:*' file-sort modification
bindkey '^[M' Lmodi-menu

Lrun-ls() { ls -ltcrh; zle redisplay; }
zle -N Lrun-ls

bindkey '\el' Lrun-ls

# Make CTRL-Z background things and unbackground them.
function fg-bg() {
  if [[ $#BUFFER -eq 0 ]]; then
    fg
  else
    zle push-input
  fi
}
zle -N fg-bg
bindkey '^Z' fg-bg

bindkey jk vi-cmd-mode

#GRML makes it slow to type eol
bindkey -r '^Ed'

function insert-datestamp () { LBUFFER+=${(%):-'%D{%Y-%m-%d}'}; }
zle -N insert-datestamp
bindkey \^Xe insert-datestamp

#ENSURE in terminal in application mode (see zsh-line-*)
#autoload -U up-line-or-beginning-search
#autoload -U down-line-or-beginning-search
#zle -N down-line-or-beginning-search
#zle -N up-line-or-beginning-search
autoload -Uz history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end  history-search-end
bindkey "^[OA" up-line-or-history
bindkey "^[OB" down-line-or-history

#bindkey "^I" expand-or-complete-with-indicator
#bindkey "^I" complete-word #Done by compinit
#Better than bare push-line
bindkey "^Q" push-line-or-edit
#"^X^B" vi-find-prev-char
bindkey "^[Q" push-line-or-edit
#"^[[Z" reverse-menu-complete
bindkey "^[/" redo
#"^[e" expand-cmd-path
bindkey "^[m" copy-prev-shell-word
bindkey "^[q" push-line-or-edit
bindkey "^Xh" _complete_help

# Menu
# when there is no reasonable completeion, press ^D! this will keep the list open
# while removing the current completion
bindkey -M menuselect '^M' .accept-line #select and accept; use ^Y to only select
bindkey -M menuselect '^J' .accept-line #select and accept; use ^Y to only select
bindkey -M menuselect '^Y' accept-line
bindkey -M menuselect '^R' history-incremental-search-backward
bindkey -M menuselect '^S' history-incremental-search-forward
bindkey -M menuselect '^[i' vi-insert

# from wincent
# fd - "find directory"
# Inspired by: https://github.com/junegunn/fzf/wiki/examples#changing-directory
# use \ec instead
#function gd() {
#  local DIR
#  DIR=$(fd --type d 2> /dev/null | fzf --no-multi --preview='test -n "{}" && ls {}' -q "$*") && cd "$DIR" && ls
#}

# fh - "find [in] history"
# Inspired by: https://github.com/junegunn/fzf/wiki/examples#command-history
# use ^R instead
#function fh() {
#  print -z $(fc -l 1 | fzf --no-multi --tac -q "$*" | sed 's/ *[0-9]*\*\{0,1\} *//')
#}
# }}}}

# Completion {{{{
#always list the full name of a pid
#TODO don't select te same twice when using tab
zstyle ':completion:*:processes' force-list always
# performance hit with ls stating files, TODO changing to faster colors not enough
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
#Use meta i for immediate menu
#No listing if too many entries #TODO add also yes=long-list
zstyle ':completion:*'               menu yes=long select #=5 would make it hard with normal menu
#start menu always
zstyle ':completion:*:expand:*'        tag-order 'expansions all-expansions' #BUG? expansions alone does not work with only one result
#Dunno what does
#zstyle ':completion:*' accept-exact-dirs yes
#case insensitive alwayas-find(tmOMZ) completion
#todo is not case sensitive in fuzzy matching
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'
#todo case

# http://www.zsh.org/mla/users/2015/msg00081.html
#zstyle ':completion:*' file-sort change
#zstyle ':completion:*' file-patterns '*:all\ files'
zstyle ':completion:most-recent-file:*' match-original both
zstyle ':completion:most-recent-file:*' file-sort change
zstyle ':completion:most-recent-file:*' file-patterns '*:all\ files'
#zstyle ':completion:most-recent-file:*' hidden all
zstyle ':completion:most-recent-file:*' completer _files
zle -C most-recent-file menu-complete _generic
bindkey "^y"      most-recent-file

compdef _options zman
#todo difference between compdef and styles?

#TODO: Does this overwrite? ( 02-Mar-2013, John Doe )
# Allow to recover from C-c or failed history expansion (thx Mikachu).
# 26may2012  +chris+
_recover_line_or_else() {
  if [[ -z $BUFFER && $CONTEXT = start && $zsh_eval_context = shfunc
    && -n $ZLE_LINE_ABORTED
    && $ZLE_LINE_ABORTED != $history[$((HISTCMD-1))] ]]; then
    LBUFFER+=$ZLE_LINE_ABORTED
    unset ZLE_LINE_ABORTED
  else
    zle .$WIDGET
  fi
}
zle -N up-line-or-history _recover_line_or_else
#notice: needed
_zle_line_finish() {
  #Grml defined
  whence zle-line-finish > /dev/null && zle-line-finish #TODO
  ZLE_LINE_ABORTED=$BUFFER
}
zle -N zle-line-finish _zle_line_finish
# }}}}

# Misc Commands {{{{
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

# Local and host-specific overrides.
# }}}}

# Local {{{{
[ ! -f $HOME/.zshrc-local.zsh ] || . $HOME/.zshrc-local.zsh



#Sources
#http://chneukirchen.org/blog/

# }}}}

# vim:set ts=8 sw=2 fdm=marker foldmarker={{{{,}}}}:
