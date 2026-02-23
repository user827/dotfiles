# history
#v#
HISTFILE=$HOME/.zsh_history
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
