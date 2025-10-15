#!/usr/bin/env bash

ansi() {
  declare -A ansi_map=(
    ["bold"]=1
    ["dim"]=2
    ["italic"]=3
    ["underline"]=4
    ["blink"]=5
    ["strike"]=9
    ["black"]=30
    ["red"]=31
    ["green"]=32
    ["yellow"]=33
    ["blue"]=34
    ["magenta"]=35
    ["cyan"]=36
    ["white"]=37
    ["black_bg"]=40
    ["red_bg"]=41
    ["green_bg"]=42
    ["yellow_bg"]=43
    ["blue_bg"]=44
    ["magenta_bg"]=45
    ["cyan_bg"]=46
    ["white_bg"]=47
  )

  local formatstr
  local str="$1"
  local idx=1
  local opt
  for opt in "${@:2}"; do
    if [[ -n ${ansi_map[$opt]} ]]; then
      formatstr+="${ansi_map[$opt]}"
    else
      formatstr+="$opt"
    fi

    if ((++idx == ${#@})); then
      formatstr+='m'
    else
      formatstr+=';'
    fi
  done

  printf '\033[%s%s\033[0m' "$formatstr" "$str"
}
