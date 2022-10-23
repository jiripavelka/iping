#!/bin/bash

TIMEOUT=1 # ping timeout in seconds

exception () {
  echo "${1:-"General exception"}" >&2
  [[ "${2}" -eq 2 ]] \
    && echo "USAGE: ${0} IP" >&2
  exit "${2:-1}"
}

# https://stackoverflow.com/a/74128284/5611007
function valid_ip () {
  [[ ${1} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]] \
    || return 1
  for i in ${1//./ }; do
    [[ ${i} -le 255 ]] \
      || return 1
  done
}

function ping_output () {
  local line
  local maxms
  local space
  local count
  line="-"
  maxms=$(( TIMEOUT * 1000 ))
  space=$(( $(tput cols) - ${#IP} - 11 ))
  count=$(( space * ${1:-maxms} / maxms ))
  [[ -z "${1}" ]] \
    && printf -- "%s TIMEOUT |" "${IP}" \
    && line="=" \
    || printf -- "%s % 4d ms |" "${IP}" "${1}"
  while (( count-- > 0 )); do
    printf -- "%s" "${line}"
  done
  echo ">"
}

function parse_ms () {
  echo "${1}" \
    | grep "^rtt" \
    | cut -d/ -f5 \
    | cut -d. -f1
}

function gping () {
  local p
  while true; do
    p=$( ping -c1 "-W${TIMEOUT}" "${IP}" ) \
      && ping_output "$(parse_ms "${p}")"
    [[ "${?}" -eq 1 ]] \
      && ping_output
    sleep 1
  done
}

[[ -n "${1}" ]] \
  || exception "Missing IP." 2
IP=${1}
valid_ip "${IP}" \
  || exception "Invalid IP format."

gping
