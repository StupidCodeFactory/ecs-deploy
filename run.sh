#!/bin/sh

set -e

error() {
    printf "✖ %s\n" "$@"
}

warn() {
    printf "➜ %s\n" "$@"
}

type_exists() {
    if [ $(type -P $1) ]; then
        return 0
    fi
    return 1
}

if ! type_exists 'ruby'; then
    error "Please install ruby or use a docker ruby image"
fi

INSTALL_BUNDLER=$(gem install bundler --no-doc 2>&1)
if [ $? -ne 0 ]; then
  error "Unable to install bundler"
  warn "$INSTALL_BUNDLER"
  exit 1
fi

INSTALL_DEPENDENCIES=$(bundle install 2>&1)
fi [ $? -ne 0 ]; then
  error "Unable to install dependencies"
  warn "$INSTALL_DEPENDENCIES"
  exit 1
fi

$WERCKER_STEP_ROOT/main.rb
