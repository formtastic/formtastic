#!/usr/bin/env sh

set -e
set -o verbose

rm -rf dummy

bundle exec rails new dummy --template=$(dirname "$0")/integration-template.rb --skip-spring --skip-turbolinks

cd dummy && export BUNDLE_GEMFILE=Gemfile

bundle exec rake test
