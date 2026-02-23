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

#bindkey jk vi-cmd-mode

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
