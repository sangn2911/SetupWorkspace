## ZSH
oh-my-zsh

## Plugins
zsh-autosuggestions  
zsh-syntax-highlighting

## Shorcut keys (.zshrc)
# Enable vi mode for better keybinding support
bindkey -v

function zle-keymap-select {
  if [[ $KEYMAP == vicmd ]]; then
    echo -ne '\e[2 q'   # block-outline (normal mode)
  else
    echo -ne '\e[6 q'   # bar cursor (insert mode)
  fi
}
zle -N zle-keymap-select

# Ensure correct cursor on startup
echo -ne '\e[6 q'

# Old bindkey
bindkey "^[z" backward-kill-word
bindkey "^z" backward-kill-word
bindkey "^[d" autosuggest-accept

## Color
Directory:  
- POWERLEVEL9K_DIR_FOREGROUND=208  
- POWERLEVEL9K_DIR_SHORTENED_FOREGROUND=208  
- POWERLEVEL9K_DIR_ANCHOR_FOREGROUND=208  
- POWERLEVEL9K_DIR_ANCHOR_BOLD=false  
Prompt arrow:  
- POWERLEVEL9K_PROMPT_CHAR_OK_{VIINS,VICMD,VIVIS,VIOWR}_FOREGROUND=7  
Time:  
- POWERLEVEL9K_TIME_FOREGROUND=242  