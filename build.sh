#!/bin/bash

SOURCE="${1}"
TARGET="${2}"
USERNAME="${3}"
EMAIL="${4}"
TOKEN="${5}"

composer=$( command -v composer )
mkdir=$( command -v mkdir )
rm=$( command -v rm )
tar=$( command -v tar )
git=$( command -v git )
date=$( command -v date )

${git} config --global user.email "${EMAIL}"
${git} config --global user.name "${USERNAME}"

${git} clone https://"${USERNAME}":"${TOKEN}"@"${SOURCE#https://}" '/root/git/source' \
  && cd '/root/git/source' || exit
${git} remote add 'target' https://"${USERNAME}":"${TOKEN}"@"${TARGET#https://}"

_timestamp() {
  timestamp=$( ${date} -u '+%Y-%m-%d %T' )
  echo "${timestamp}"
}

flarum_eng() {
  name="flarum.eng"

  ${mkdir} -p "${name}"                                   \
    && ${composer} create-project flarum/flarum "${name}" \
    && ${tar} -cJf "${name}.tar.xz" "${name}"             \
    && ${rm} -rf "${name}"
}

flarum_rus() {
  name="flarum.rus"

  ${mkdir} -p "${name}"                                           \
    && ${composer} create-project flarum/flarum "${name}"         \
    && cd "${name}"                                               \
    && ${composer} require 'marketplace/flarum-l10n-core-russian' \
    && cd ..                                                      \
    && ${tar} -cJf "${name}.tar.xz" "${name}"                     \
    && ${rm} -rf "${name}"
}

flarum_eng && flarum_rus

${git} add .                                      \
  && ${git} commit -a -m "Build: $( _timestamp )" \
  && ${git} push 'target'

exit 0
