# vim:ft=zsh ts=2 sw=2 sts=2
#
# ariporad's Theme - https://gist.github.com/3712874
# A ZSH theme based off agnoster's theme, but without powerline or backgrounds.
#
# # README
# I reccomend using iTerm2 if you're on a Mac, it's much better.
#  
#
# # Goals
#
# The aim of this theme is to only show you *relevant* information. Like most
# prompts, it will only show git information when in a git working directory.
# However, it goes a step further: everything from the current user and
# hostname to whether the last call exited with an error to whether background
# jobs are running in this shell will all be displayed automatically when
# appropriate.

### Segment drawing
# A few utility functions to make it easy and re-usable to draw segmented prompts
PRIMARY_FG=white

# Characters
DETACHED="\u27a6"
CROSS="\u2718"
LIGHTNING="\u26a1"
GEAR="\u2699"

# Begin a segment
# Takes one arguments, thr foreground. If ommited, the default is rendered.
# We render to a buffer, so that we can automatically add a trailing space,
# then remove the last one

PROMPT_BUFFER=""
prompt_segment() {
  local fg
  [[ -n $1 ]] && fg="%F{$1}" || fg="%f"
  PROMPT_BUFFER+="%{$fg%}"
  [[ -n $2 ]] && PROMPT_BUFFER+="$2 "
}

# End the prompt, closing any open segments and printing the prompt
prompt_end() {
  print -n ${${:-$PROMPT_BUFFER}[1,-2]}
  print -n "%{%k%}"
  print -n "%{%f%}"
  print -n "%{%b%}"
}

### Prompt components
# Each component will draw itself, and hide itself if no information needs to be shown

# Status:
# - am I root
# - are there background jobs?
prompt_status() {
  local symbols
  symbols=()
  [[ $UID -eq 0 ]] && symbols+="%{%F{yellow}%}$LIGHTNING"
  [[ $(jobs -l | wc -l) -gt 0 ]] && symbols+="%{%F{cyan}%}$GEAR"

  

  [[ -n "$symbols" ]] && prompt_segment default "$symbols"
}

# Context: user@hostname (who am I and where am I)
prompt_context() {
  local user=`whoami`

  if [[ "$user" != "$DEFAULT_USER" || -n "$SSH_CONNECTION" ]]; then
    prompt_segment default "%(!.%{%F{grey}%}.)$user@%m"
  fi
}

# Dir: current working directory
prompt_dir() {
  prompt_segment blue '%~'
}

# Git: branch/detached head, dirty status
prompt_git() {
  local color ref
  is_dirty() {
    test -n "$(git status --porcelain --ignore-submodules)"
  }
  ref="$vcs_info_msg_0_"
  if [[ -n "$ref" ]]; then
    if is_dirty; then
      color=red
      ref="${ref}"
    else
      color=green
      ref="${ref}"
    fi
    if [[ "${ref/.../}" == "$ref" ]]; then
      ref="$ref"
    else
      ref="$DETACHED ${ref/.../}"
    fi
    prompt_segment $color "$ref"
  fi
}

# Prompt (the arrow):
# - Status of last job (red/green)
prompt_prompt() {
  prompt_segment default "%(?:%{$fg_bold[green]%}➜:%{$fg_bold[red]%}➜%s)"
}

## Main prompt
prompt_ariporad_main() {
  RETVAL=$?
  prompt_status
  prompt_context
  prompt_dir
  prompt_git
  prompt_prompt
  prompt_end
}

prompt_ariporad_precmd() {
  vcs_info
  PROMPT='%{%f%b%k%}$(prompt_ariporad_main) '
}

prompt_ariporad_setup() {
  autoload -Uz add-zsh-hook
  autoload -Uz vcs_info

  prompt_opts=(cr subst percent)

  add-zsh-hook precmd prompt_ariporad_precmd

  zstyle ':vcs_info:*' enable git
  zstyle ':vcs_info:*' check-for-changes false
  zstyle ':vcs_info:git*' formats '%b'
  zstyle ':vcs_info:git*' actionformats '%b (%a)'
}

prompt_ariporad_setup "$@"