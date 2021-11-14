# Oh My Zsh Dark Git Theme by Alexey Borealis
# Inspired by power10k and agnoster themes


#### START CUSTOM SETTINGS ####
# Configure your colors
GIT_DIRTY_BG_COLOR=214
GIT_DIRTY_FG_COLOR=black
GIT_CLEAR_BG_COLOR=70
GIT_CLEAR_FG_COLOR=black
GIT_CONFLICT_BG_COLOR=88
GIT_CONFLICT_FG_COLOR=white
PATH_BG_COLOR=236
PATH_FG_COLOR=250
HOSTNAME_BG_COLOR=238
HOSTNAME_FG_COLOR=214
VENV_FG_COLOR=38

# Configure your symbols (default set requires Nerd Font family)
SEPARATOR="\ue0b0"
LEFT_ICON="\uE0B7"
RIGHT_ICON="\uE0B5"
GIT_DIRTY_ICON="\uF46A"
GIT_BRANCH_ICON="\ue0a0"
GIT_DETACHED_ICON="\uF064"
GIT_STASH_ICON="\uF01C"
FOLDER_ICON="\uF07c"
VENV_ICON="\uF0A0"
PROMPT_INVITE_ICON="\u276F"
TIME_ICON="\uE388"

# Display settings
SHORTEN_PATH_BY=2       # Maximum subfolders to show in path
TRANSIENT_PROMPT=true   # Display short version of prompt for executed commands
#### END CUSTOM SETTINGS ####

# 1. Git Info Section
autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" check-for-changes true
zstyle ":vcs_info:git:*" formats "%b"
zstyle ":vcs_info:git:*" actionformats "%b$LEFT_ICON%a$RIGHT_ICON"

function is_git_repo() {
  $(git status >/dev/null 2>&1)
}

function is_git_dirty() {
  [[ -n $(git status -s) ]] && return 0 || return 1
}

function is_git_attached_state() {
  $(git symbolic-ref HEAD >/dev/null 2>&1) 
}

function git_stashes_count() {
  echo $(git stash list | grep "stash" | wc -l | sed 's/ //g')
}

function is_git_merge_conflict() {
  [[ $(git diff --name-only --diff-filter=AA --diff-filter=UU | wc -l | sed 's/ //g') != "0" ]] && return 0 || return 1
}

function git_localbranch_info() {
  stashes=$(git_stashes_count)
  [[ $stashes != "0" ]] && stashes="$GIT_STASH_ICON $stashes" || stashes=""
  is_git_attached_state && pointer=$GIT_BRANCH_ICON || pointer=$GIT_DETACHED_ICON
  is_git_dirty && dirty_icon=$GIT_DIRTY_ICON

  echo $pointer $vcs_info_msg_0_ $dirty_icon $stashes
}

function _git_prompt() {
  if is_git_repo; then
    if is_git_merge_conflict; then
      BG_COLOR=$GIT_CONFLICT_BG_COLOR
      FG_COLOR=$GIT_CONFLICT_FG_COLOR
    elif is_git_dirty; then
      BG_COLOR=$GIT_DIRTY_BG_COLOR
      FG_COLOR=$GIT_DIRTY_FG_COLOR
    else
      BG_COLOR=$GIT_CLEAR_BG_COLOR
      FG_COLOR=$GIT_CLEAR_FG_COLOR
    fi

    echo %{%K{$BG_COLOR}%}$SEPARATOR%{%F{$FG_COLOR}%} $(git_localbranch_info) \
    %{%F{$BG_COLOR}%K{$PATH_BG_COLOR}%}$SEPARATOR
  else
    echo %{%K{$PATH_BG_COLOR}%}$SEPARATOR
  fi
}

# 2. Short Prompt Section
export VIRTUAL_ENV_DISABLE_PROMPT=yes

function new_line_invite {
  [ $VIRTUAL_ENV ] && ENV="%{%F{$VENV_FG_COLOR}%}$VENV_ICON env %{%f%}"
  echo $ENV%{%F{green}%}$PROMPT_INVITE_ICON %{%f%}
}

# 3. Main Prompt Section

function display_status_and_user() {
  STATUS_OF_PREV_COMMAND="%(?.%{%F{green}%}✔.%{%F{red}%}✘)"
  echo %{%K{$HOSTNAME_BG_COLOR}%} $STATUS_OF_PREV_COMMAND%{%F{$HOSTNAME_FG_COLOR}%} %n %{%F{$HOSTNAME_BG_COLOR}%}
}

function display_curr_path() {
  # Shorten long paths to ~/.../dir1/dir2/
  MAX_PATH_DEPTH=$(($SHORTEN_PATH_BY+2))
  SHORT_PATH=" %($MAX_PATH_DEPTH~|%-1~/…/%$SHORTEN_PATH_BY~|%~)"

  echo %{%F{$PATH_FG_COLOR}%} $FOLDER_ICON $SHORT_PATH %{%k%F{$PATH_BG_COLOR}%}$SEPARATOR%{%f%}
}

set_prompt() {
  NEWLINE=$'\n'
  PROMPT='$(display_status_and_user)$(_git_prompt)$(display_curr_path)${NEWLINE}$(new_line_invite)'
}

precmd_functions+=( set_prompt )

TIME="%F{green}[%*]%{%f%}"
RPROMPT=$TIME

# 4. Transient Prompt Section

set_short_prompt() {
  if [[ $PROMPT != "$(new_line_invite)" ]]; then
    PROMPT=$(new_line_invite)
    zle .reset-prompt
  fi
}

zle-line-finish() {
  if $TRANSIENT_PROMPT; then
    set_short_prompt
  fi
}
