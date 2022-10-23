#!/bin/bash

exception () {
  MSG=${1:-"Unexpected exception"}
  echo "${MSG}" >&2
  EC="${2:-1}"
  [[ ${EC} -eq 2 ]] \
    && echo "USAGE: ${0} IP" >&2
  exit "${EC}"
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
  local ms
  local step
  ms=${1}
  [[ -z "${ms}" ]] \
    && printf -- "%s TIMEOUT |" "${IP}" \
    && ms=$(( TIMEOUT * 1000 )) \
    || printf -- "%s % 4d ms |" "${IP}" "${ms}"
  space=$(( $(tput cols) - ${#IP} - 11 ))
  step=$(( TIMEOUT * 1000 / space ))
  over=$(( TIMEOUT * 1000 - step * space ))
  while [ "${ms}" -gt "${over}" ]; do
    printf "-"
    (( ms -= step ))
  done
  echo ">"
}

function parse_ms () {
  echo "${1}" \
    | grep ^rtt \
    | cut -d/ -f5 \
    | cut -d. -f1
}

function gping () {
  while true; do
    p=$( ping -c1 "-W${TIMEOUT}" "${IP}" ) \
      && ping_output "$(parse_ms "${p}")"
    [[ "${?}" -eq 1 ]] \
      && ping_output
    sleep 1
  done
}

TIMEOUT=1
[[ -n "${1}" ]] \
  || exception "Missing IP." 2
IP=${1}
valid_ip "${IP}" \
  || exception "Invalid IP format." 1

gping
