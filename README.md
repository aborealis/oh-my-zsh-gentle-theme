# Gentle Oh-My-Zsh Theme
This theme is for git users. 

![Screenshot](https://raw.githubusercontent.com/aborealis/oh-my-zsh-gentle-theme/main/screenshot1.png)

## Installation

1. Copy gentle.zsh-theme file into ~./oh-my-zsh/custom/themes/ folder.
2. In your ~./zsh configuration file, find the row starting with ZSH_THEME=... and change it to ZSH_THEME="gentle"

## Compatibility and Customization

By default, this theme is adopted to dark-background terminals and uses the icons from Nerd Fonts family (https://www.nerdfonts.com/). My personal preference is Meslo Nerd Font with this theme.

You can easily adjust colors and icons according to your needs by editing variables at the beginning of "gentle.zsh-theme" file.

Everything between "START CUSTOM SETTINGS" and "END CUSTOM SETTINGS" comments is safe to modify.

If you do not want particular icons to display, simply comment on the correspondent variable.

## What Does It Show?

### Git Statuses

1. Current branch 
2. Detached head state
3. Dirty working direcory (orange / green)
4. Stashes (and number of stashes)
5. Merge conflicts (red background)
6. Action state (merge, rebase, cherry pick, etc)

## System Statuses

1. Username
2. Status (success/fail) of previous terminal command
3. Current path
4. Virtual environment info
5. Time when the command was executed

![Screenshot](https://raw.githubusercontent.com/aborealis/oh-my-zsh-gentle-theme/main/screenshot2.png)