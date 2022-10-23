#!/bin/bash

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

stamp () {
  [[ ${1} -lt 1 ]] \
    && printf "%s" "${2}" \
    && return
  printf "\n%s %s" "$(date)" "${2}" # local format date
  printf '%(%Y-%m-%d %H:%M:%S)T %s\n' -1 "${2}" >> "${LOG_FILE}"
}

iping () {
  local i=0
  while true; do
  # shellcheck disable=SC2015
  ping -c1 -W2 "${IP}" >/dev/null 2>&1 \
    && printf "." \
    && i=0 \
    || stamp $(( i++ )) "${?}"
  sleep 4
  done
}

[[ -n "${1}" ]] \
  || exception "Missing IP." 2
IP=${1}
valid_ip "${IP}" \
  || exception "Invalid IP format." 1
LOG_DIR=/var/log/iping
mkdir -p "${LOG_DIR}" \
  || exception "Unable to create log folder."
LOG_FILE=/var/log/iping/${IP}
touch "${LOG_FILE}" \
  || exception "Unable to write into log file."

iping
