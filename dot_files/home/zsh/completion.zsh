COMPDUMPFILE=${COMPDUMPFILE:-$HOME/.zsh/zcompdump}
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
    GRML_COMP_CACHE_DIR=${GRML_COMP_CACHE_DIR:-$HOME/.zsh/cache}
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

# Completion part2 {{{{
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

# vim:set ts=8 sw=2 fdm=marker foldmarker={{{{,}}}}:
