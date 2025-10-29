PROMPT='%{$fg_bold[magenta]%}[${TIME_NOW}]%n ${ARROW} %{$fg_bold[red]%}%~${RESET_COLOR} $(git_prompt_info)
${ARROW} ${RESET_COLOR}'
ARROW="%{$fg[white]%}➜"
TIME_NOW="%D{%I:%M%p}"

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[blue]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$fg[blue]%})"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}*"
ZSH_THEME_GIT_PROMPT_CLEAN=""
RESET_COLOR="%{$reset_color%}"