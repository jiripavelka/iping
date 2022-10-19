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

timestamp () {
  printf "\n%s %s" "$(date)" "${1}" # local format date
  printf '%(%Y-%m-%d %H:%M:%S)T %s\n' -1 "${1}" >> "${LOG_FILE}"
}

iping () {
  # shellcheck disable=SC2015
  ping -c1 -W2 "${1}" >/dev/null 2>&1 \
    && printf "." \
    || timestamp "${?}"
  sleep 4
  iping "${1}"
}

[[ -n "${1}" ]] \
  || exception "Missing IP." 2
valid_ip "${1}" \
  || exception "Invalid IP format." 1
LOG_DIR=/var/log/iping
mkdir -p "${LOG_DIR}" \
  || exception "Unable to create log folder."
LOG_FILE=/var/log/iping/${1}
touch "${LOG_FILE}" \
  || exception "Unable to write into log file."

iping "${1}"
