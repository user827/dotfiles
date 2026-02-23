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
