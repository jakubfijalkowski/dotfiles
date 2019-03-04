#!/usr/bin/env zsh

files=($(ls *.txt))
lines=($(pacman -Qqe))
excludes="$(pacman -Qqg base base-devel xorg | tr '\n' ' ')"

function _print_help() {
  local f
  local i=1
  for f in ${files[@]}; do
    echo -n "$i) $f; "
    ((i = i + 1))
  done
  echo ''
}


function _ask() {
  local file=$1
  local result=$2
  local user_answer

  if [[ "$excludes" =~ "$file" ]]; then
    eval $result="''"
  else
    echo -n "$file: "
    read user_answer
    if [[ "$user_answer" == "0" ]]; then
      _print_help
      _ask $1 $result
    elif [[ "$user_answer" == "d" ]]; then
      eval $result="''"
    else
      local final_result=${files[$user_answer]}
      eval $result="'$final_result'"
    fi
  fi
}

function _cleanup() {
  local res
  echo -n 'Do you want to clean the files [y/n]? '
  read res
  if [[ "$res" == "y" ]]; then
    local f
    for f in ${files[@]}; do
      echo '' > $f
    done
  elif [[ "$res" != "n" ]]; then
    _cleanup
  fi
}

function _sort_files() {
  local res
  echo -n 'Do you want to sort the results [y/n]? '
  read res
  if [[ "$res" == "y" ]]; then
    local f
    local temp
    for f in ${files[@]}; do
      temp=($(cat $f | sort | uniq))
      printf "%s\n" "${temp[@]}" > $f
    done
  elif [[ "$res" != "n" ]]; then
    _sort_files
  fi
}

function _run() {
  for l in ${lines[@]}; do
    _ask $l answer
    if [[ "$answer" != "" ]]; then
      echo $l >> $answer
    fi
  done
}

function _prepare() {
  echo 'base' >> base.txt
  echo 'base-devel' >> base.txt
  echo 'xorg' >> base.txt
}

_cleanup
_prepare
_run
_sort_files
