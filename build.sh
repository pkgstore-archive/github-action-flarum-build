#!/bin/bash

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

init() {
  # Vars.
  REPO="${1}"
  USER="${2}"
  EMAIL="${3}"
  TOKEN="${4}"

  # Apps.
  composer="$( command -v composer )"
  mkdir="$( command -v mkdir )"
  rm="$( command -v rm )"
  tar="$( command -v tar )"
  git="$( command -v git )"
  date="$( command -v date )"

  # Git config.
  ${git} config --global user.email "${EMAIL}"
  ${git} config --global user.name "${USER}"
  ${git} config --global init.defaultBranch 'main'

  # Run.
  git_clone       \
    && build_eng  \
    && build_rus  \
    && git_push
}

init "$@"

# -------------------------------------------------------------------------------------------------------------------- #
# GIT: CLONE REPOSITORY.
# -------------------------------------------------------------------------------------------------------------------- #

git_clone() {
  REPO_AUTH="https://${USER}:${TOKEN}@${REPO#https://}"

  ${git} clone "${REPO_AUTH}" '/root/git/build' && cd '/root/git/build' || exit 1
  ${git} remote add 'build' "${REPO_AUTH}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# BUILD: FLARUM ENG.
# -------------------------------------------------------------------------------------------------------------------- #

build_eng() {
  name="flarum.eng"

  ${mkdir} -p "${name}" \
    && ${composer} create-project flarum/flarum "${name}" \
    && ${tar} -cJf "${name}.tar.xz" "${name}" \
    && ${rm} -rf "${name}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# BUILD: FLARUM RUS.
# -------------------------------------------------------------------------------------------------------------------- #

build_rus() {
  name="flarum.rus"

  ${mkdir} -p "${name}" \
    && ${composer} create-project flarum/flarum "${name}" \
    && _pushd "${name}" \
    && ${composer} require 'flarum-lang/russian' \
    && _popd \
    && ${tar} -cJf "${name}.tar.xz" "${name}" \
    && ${rm} -rf "${name}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# GIT: PUSH FLARUM BUILDS TO STORAGE.
# -------------------------------------------------------------------------------------------------------------------- #

git_push() {
  ts="$( _timestamp )"

  ${git} add . \
    && ${git} commit -a -m "BUILD: ${ts}" \
    && ${git} push 'build'
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

# Pushd.
_pushd() {
  command pushd "$@" > /dev/null || exit 1
}

# Popd.
_popd() {
  command popd > /dev/null || exit 1
}

# Timestamp.
_timestamp() {
  ${date} -u '+%Y-%m-%d %T'
}

exit 0
