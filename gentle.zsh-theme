# Oh My Zsh Dark Git Theme by Alexey Borealis


#### START CUSTOM SETTINGS ####
# Configure your colors
GIT_DIRTY_BG_COLOR=214
GIT_CLEAR_BG_COLOR=70
GIT_CONFLICT_BG_COLOR=88
GREEN=73
PATH_BG_COLOR=236
PATH_FG_COLOR=250
HOSTNAME_BG_COLOR=238
HOSTNAME_FG_COLOR=214
VENV_FG_COLOR=38

# Configure your symbols (default set requires Nerd Font family)
SEPARATOR="\ue0b0"
LEFT_ICON="\uE0B7"
RIGHT_ICON="\uE0B5"
REFRESH_ICON="\uF46A"
BRANCH_ICON="\ue0a0"
DETACHED_ICON="\uF064"
STASH_ICON="\uF01C"
FOLDER_ICON="\uF07c"
VENV_ICON="\uF0A0"
PROMPT_INVITE_ICON="\u276F"
TIME_ICON="\uE388"
THREE_DOTS_ICON="\u2026"

# Display settings
SHOW_VIRTENV_NAME=true  # Show/hide the name of current virt. env.
SHORTEN_PATH_BY=4       # Maximum subfolders to show in path
#### END CUSTOM SETTINGS ####

ZSH_THEME_GIT_PROMPT_DIRTY=" $REFRESH_ICON"

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" check-for-changes true
zstyle ":vcs_info:git:*" formats "%b"
zstyle ":vcs_info:git:*" actionformats "%b$LEFT_ICON%a$RIGHT_ICON"

function _git_prompt_info() {
  if [[ $(git symbolic-ref HEAD 2> /dev/null) ]]; then 
    pointer=$BRANCH_ICON
  else
    pointer=$DETACHED_ICON
  fi

  stashes_count=$(git stash list | grep "stash" | wc -l | sed 's/ //g')
  if [[ $stashes_count != "0" ]]; then 
    stash_info=" $STASH_ICON $stashes_count"
  fi  
  echo "$pointer $vcs_info_msg_0_"$(parse_git_dirty)"$stash_info"
}

function _git_prompt() {
  if $(git rev-parse --is-inside-work-tree >/dev/null 2>&1); then
    BG_COLOR=$GIT_CLEAR_BG_COLOR
    if [[ -n $(parse_git_dirty) ]]; then
      BG_COLOR=$GIT_DIRTY_BG_COLOR
      FG_COLOR=black
    fi

    if [[ $(git diff --name-only --diff-filter=AA --diff-filter=UU | wc -l | sed 's/ //g') != "0" ]]; then
      BG_COLOR=$GIT_CONFLICT_BG_COLOR
      FG_COLOR=white
    fi

    echo "%{%K{$BG_COLOR}%}$SEPARATOR%{%F{$FG_COLOR}%} $(_git_prompt_info) %{%F{$BG_COLOR}%K{$PATH_BG_COLOR}%}$SEPARATOR"
  else
    echo "%{%K{$PATH_BG_COLOR}%}$SEPARATOR"
  fi
}

export VIRTUAL_ENV_DISABLE_PROMPT=yes
function new_line_invite {
  if [ $VIRTUAL_ENV ]; then 
    echo  "%{%F{white}%}%{%F{$VENV_FG_COLOR}%}$VENV_ICON env%{%f%} $PROMPT_INVITE_ICON %{%f%}"
  else
    echo "%{%F{white}%}$PROMPT_INVITE_ICON %{%f%}"
  fi
}

function virtual_env_info {
  if [ $VIRTUAL_ENV ]; then
    echo "%{%F{$VENV_FG_COLOR}%}$(basename $VIRTUAL_ENV) %{%f%}"
  fi
}

CLEAR_FONT="%{%f%b%k%}"
TIME="%F{$GREEN}[%*]%{%f%}"
MAX_PATH_DEPTH=$(($SHORTEN_PATH_BY+1))
PATH_FOLDERS=%($MAX_PATH_DEPTH~|$(echo $THREE_DOTS_ICON)/%$SHORTEN_PATH_BY~|%~)

PROMPT_HOST="%{%K{$HOSTNAME_BG_COLOR}%} %(?.%{%F{$GREEN}%}✔.%{%F{red}%}✘)%{%F{$HOSTNAME_FG_COLOR}%} %n %{%F{$HOSTNAME_BG_COLOR}%}"
PROMPT_DIR="%{%F{$PATH_FG_COLOR}%} $(echo $FOLDER_ICON)  $PATH_FOLDERS  %{%k%F{$PATH_BG_COLOR}%}$(echo $SEPARATOR)%{%f%}"

PROMPT=$CLEAR_FONT$PROMPT_HOST'$(_git_prompt)'$PROMPT_DIR'
$(new_line_invite)'

if $SHOW_VIRTENV_NAME; then
  RPROMPT='$(virtual_env_info)'$TIME
else
  RPROMPT=$TIME
fi
