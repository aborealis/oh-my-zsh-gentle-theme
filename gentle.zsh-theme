# Oh My Zsh Dark Git Theme by Alexey Borealis
# Inspired by power10k and agnoster themes
# Based on Zsh framework "vcs_info"

#### START CUSTOM SETTINGS ####
# Configure your colors
GIT_DIRTY_BG=214        # Orange by default
GIT_DIRTY_FG=black      # Black by default
GIT_CLEAR_BG=70         # Fresh-green by default
GIT_CLEAR_FG=black      # Black by default
GIT_CONFLICT_BG=88      # Red by default
GIT_CONFLICT_FG=white   # White by default
PATH_BG=236             # Dark gray by default
PATH_FG=250             # Light gray by default
USER_BG=238             # Gray by default
USER_FG=214             # Oragnge by default
VENV_FG=38              # Light blue by default

# Configure your symbols (default set requires Nerd Font family)
SEPARATOR="\ue0b0"                # Triangle symbol by default
LEFT_ICON="\uE0B7"                # Large parenthesis by default
RIGHT_ICON="\uE0B5"               # Large parenthesis by default
GIT_DIRTY_ICON="\uF46A"           # Sync icon by default
GIT_BRANCH_ICON="\uFB2B"          # Branch icon by default
GIT_REMOTE_ICON="\uE0B1 \uF819"   # Triangle separator and remote host icon 
GIT_DETACHED_ICON="\uF064"        # Curved arrow by default
GIT_STASH_ICON="\uF01C"           # Box icon by default
FOLDER_ICON="\uF07c"              # Filled open folder icon
VENV_ICON="\uF0A0"                # Server icon by default
PROMPT_INVITE_ICON="\u276F"       # Right angle bracket

# Display settings
SHORTEN_PATH_BY=2                 # Maximum subfolders to show in the path
TRANSIENT_PROMPT=true             # Display short version of prompt next to already executed commands
SHOW_REMOTE_BRANCH_NAME=false     # If "false" then displays the word "remote"
SHOW_VIRT_ENV_NAME=false          # If "false" then displays the word "env"
#### END CUSTOM SETTINGS ####

export VIRTUAL_ENV_DISABLE_PROMPT=yes

autoload -Uz vcs_info
precmd_vcs_info() { vcs_info }
precmd_functions+=( precmd_vcs_info )
setopt prompt_subst

zstyle ":vcs_info:*" enable git
zstyle ":vcs_info:*" check-for-changes false
zstyle ":vcs_info:git:*" formats "%b%c%m"
zstyle ":vcs_info:git:*" actionformats "%b%c%m$LEFT_ICON%a$RIGHT_ICON"
zstyle ":vcs_info:git*+set-message:*" hooks git_detached git_dirty git_stashes git_remote


function +vi-git_detached {
  if $(git symbolic-ref HEAD >/dev/null 2>&1); then
    hook_com[branch]="$GIT_BRANCH_ICON ${hook_com[branch]}"
  else
    hook_com[branch]="$GIT_DETACHED_ICON  ${hook_com[branch]}"
  fi
  return 0
}

function +vi-git_dirty() {
  local git_dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  (( $git_dirty )) && hook_com[staged]+=" $GIT_DIRTY_ICON"
  return 0
}

function +vi-git_stashes() {
  local stashes=$(git stash list | grep "stash" | wc -l | tr -d ' ')
  (( $stashes )) && hook_com[misc]=" $GIT_STASH_ICON ${stashes}${hook_com[misc]}"
  return 0
}


# Shows remote branch name for remote-tracking branches with
# -N/+N when your local branch is ahead-of or behind remote HEAD
function +vi-git_remote() {
    local loc_branch=$(git branch --show-current)
    local remote
    local ahead behind
    local gitstatus

    if $SHOW_REMOTE_BRANCH_NAME; then
      remote=$(git rev-parse --verify ${loc_branch}@{upstream} --symbolic-full-name 2>/dev/null)
      remote=${${remote}/refs\/remotes\/}
    else
      remote="remote"
    fi
    ahead=$(git rev-list ${loc_branch}@{upstream}..HEAD 2>/dev/null | wc -l | tr -d ' ')
    behind=$(git rev-list HEAD..${loc_branch}@{upstream} 2>/dev/null | wc -l | tr -d ' ')

    if (( $ahead )); then 
      gitstatus="+${ahead}/-${ahead}"
    elif (( $behind )); then 
      gitstatus+="+${behind}/+${behind}/"
    fi

    [[ $gitstatus != "" ]] && hook_com[misc]+=" $GIT_REMOTE_ICON $remote $gitstatus"

    return 0
}


# Set git bg color
function colorize_git_prompt() {
  local separator1 separator2
  local bg_color fg_color
  local git_dirty=$(git status --porcelain 2>/dev/null | wc -l | tr -d ' ')
  local git_conflict=$(git diff --name-only --diff-filter=AA --diff-filter=UU | wc -l | tr -d ' ')

  if (( $git_conflict )); then
    bg_color=$GIT_CONFLICT_BG
    fg_color=$GIT_CONFLICT_FG
  elif (( $git_dirty )); then
    bg_color=$GIT_DIRTY_BG
    fg_color=$GIT_DIRTY_FG
  else
    bg_color=$GIT_CLEAR_BG
    fg_color=$GIT_CLEAR_FG
  fi

  separator1=$(echo %K{$bg_color}%F{$USER_BG}$SEPARATOR)
  seperator2=$(echo %K{$PATH_BG}%F{$bg_color}$SEPARATOR)
  vcs_info_msg_0_="$separator1%F{$fg_color}%K{$bg_color} $vcs_info_msg_0_ $seperator2"
}

# 2nd line of the prompt
function new_line {
  local venv_info
  local venv_name
  if $SHOW_VIRT_ENV_NAME; then
    venv_name=$(basename "$VIRTUAL_ENV")
  else
    venv_name="env"
  fi
  [ $VIRTUAL_ENV ] && venv_info="%F{$VENV_FG}$VENV_ICON $venv_name %f"
  echo $venv_info%F{green}$PROMPT_INVITE_ICON %f
}

precmd() {
  vcs_info

  local cmd_check="%(?.%F{green}✔.%F{red}✘)"
  local username="%K{$USER_BG} $cmd_check %F{$USER_FG}%n "
  local env_info

  # Shorten long paths to ~/.../dir1/dir2/
  local short_path=" %($(($SHORTEN_PATH_BY+2))~|%-1~/…/%$SHORTEN_PATH_BY~|%~) "
  short_path=$(echo %K{$PATH_BG}%F{$PATH_FG} $FOLDER_ICON ${short_path}%F{$PATH_BG}%k$SEPARATOR%f)

  # 1st line of PS1
  if [[ $vcs_info_msg_0_ == "" ]]; then
      PS1="${username}%F{$USER_BG}%K{$PATH_BG}${SEPARATOR}${short_path}"
  else
      colorize_git_prompt
      PS1="${username}${vcs_info_msg_0_}${short_path}"
  fi

  # 2nd line of PS1
  PS1=$(echo $PS1'\n'$(new_line))

}

set_short_prompt() {
  local short_prompt=$(new_line)
  if [[ $PROMPT != $short_prompt ]]; then
    PROMPT=$short_prompt
    zle .reset-prompt
  fi
}

zle-line-finish() {
  if $TRANSIENT_PROMPT; then
    set_short_prompt
  fi
}

TIME="%F{green}[%*]%{%f%}"
RPROMPT=$TIME
