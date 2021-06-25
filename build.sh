#!/bin/bash

REPO="${1}"
USER="${2}"
EMAIL="${3}"
TOKEN="${4}"

composer=$( command -v composer )
mkdir=$( command -v mkdir )
rm=$( command -v rm )
tar=$( command -v tar )
git=$( command -v git )
date=$( command -v date )

${git} config --global user.email "${EMAIL}"
${git} config --global user.name "${USER}"

REPO_AUTH="https://${USER}:${TOKEN}@${REPO#https://}"

${git} clone "${REPO_AUTH}" '/root/git/build' && cd '/root/git/build' || exit 1
${git} remote add 'build' "${REPO_AUTH}"

_timestamp() {
  ${date} -u '+%Y-%m-%d %T'
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

  ${mkdir} -p "${name}"                                   \
    && ${composer} create-project flarum/flarum "${name}" \
    && pushd "${name}"                                    \
    && ${composer} require 'flarum-lang/russian'          \
    && popd                                               \
    && ${tar} -cJf "${name}.tar.xz" "${name}"             \
    && ${rm} -rf "${name}"
}

flarum_eng && flarum_rus

ts=$( _timestamp )

${git} add .                            \
  && ${git} commit -a -m "Build: ${ts}" \
  && ${git} push 'build'

exit 0
