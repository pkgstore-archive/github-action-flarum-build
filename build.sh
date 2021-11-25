#!/bin/bash
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
  git_clone && build_eng && build_rus && git_push
}

# PUSHD command.
_pushd() {
  command pushd "$@" > /dev/null || exit 1
}

# POPD command.
_popd() {
  command popd > /dev/null || exit 1
}

# Timestamp.
_timestamp() {
  ${date} -u '+%Y-%m-%d %T'
}

# Clone repository.
git_clone() {
  REPO_AUTH="https://${USER}:${TOKEN}@${REPO#https://}"

  ${git} clone "${REPO_AUTH}" '/root/git/build' && cd '/root/git/build' || exit 1
  ${git} remote add 'build' "${REPO_AUTH}"
}

# Build Flarum ENG.
build_eng() {
  name="flarum.eng"

  ${mkdir} -p "${name}" \
    && ${composer} create-project flarum/flarum "${name}" \
    && ${tar} -cJf "${name}.tar.xz" "${name}" \
    && ${rm} -rf "${name}"
}

# Build Flarum RUS.
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

# Push Flarum builds to storage.
git_push() {
  ts="$( _timestamp )"

  ${git} add . \
    && ${git} commit -a -m "BUILD: ${ts}" \
    && ${git} push 'build'
}

init "$@"
exit 0
