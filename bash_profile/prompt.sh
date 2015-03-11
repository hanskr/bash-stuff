
# Prompt
# Powerline font required, utf-8 support and git
function timer_start {
  timer=${timer:-$SECONDS}
}

function timer_stop {
  timer_show=$((SECONDS - timer))
  unset timer
}

trap 'timer_start' DEBUG

GREY='\[\033[01;30m\]'
DEFAULT='\[\033[00m\]'

seg_sep=$'\uE0B0'

function set_git_seg {
  local reset=$'\001\033[00m\002'
  local post_path=$'\001\e[48;5;148m\002\001\e[38;5;31m\002'
  local end_path=$'\001\e[38;5;31m\002'
  local pre_git=$'\001\e[48;5;148m\002\001\e[38;5;237m\002'
  local post_git=$'\001\e[38;5;148m\002'
  local git_status=$(__git_ps1 "%s")
  if [ -z "$git_status" ]; then
    git_seg="$reset$end_path$seg_sep"
  else
    git_seg="$post_path$seg_sep$pre_git $git_status $reset$post_git$seg_sep"
  fi
}

function set_path_seg {
  local post_host=$'\001\e[48;5;31m\002\001\e[38;5;238m\002'
  local pre_path=$'\001\e[38;5;15m\002\001\e[48;5;31m\002'
  local pre_sep=$'\001\e[48;5;31m\002\001\e[38;5;244m\002'  
  local post_sep=$'\001\e[38;5;15m\002\001\e[48;5;31m\002'
  local sep=$pre_sep$'\uE0B1'$post_sep
  wdir=$(pwd | sed "s|$HOME|~|")
  path_seg="$post_host$seg_sep$pre_path ${wdir//\// $sep }"
}

function set_fill_seg {
  local left_prompt=" $(whoami)@$(hostname -s) ; ${wdir//\// $sep } ; $(__git_ps1 '..%s...')  ;"
  local right_prompt="[last: ${timer_show}s][$(date +%H:%M:%S)]"
  local columns=$(tput cols)
  local fillsize=${columns}-${#left_prompt}-${#right_prompt}-1
  local spaces=$(printf ' %.0s' {1..400})
  fill_seg=$DEFAULT${spaces:0:$fillsize}
}

function set_time_seg {
  timer_stop
  local pre_time=$'\001\033[01;30m\002'
  time_seg="$pre_time[last: ${timer_show}s][\t]"
}


function set_prompt {
  local pre_host="\[\e[38;5;250m\]\[\e[48;5;238m\]"
  local promtp_que=$'\u279C'$DEFAULT

  set_time_seg
  set_path_seg
  set_git_seg
  set_fill_seg
  
  PS1="\n$pre_host \u@\h $path_seg $git_seg$fill_seg$time_seg\n $promtp_que "    
}

PROMPT_COMMAND="set_prompt"
