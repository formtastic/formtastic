#!/usr/bin/env sh

set -e
set -o verbose

test_app=dummy

rm -rf ${test_app}

bundle exec rails new ${test_app} \
  --template=$(dirname "$0")/integration-template.rb \
  --skip-bootsnap \
  --skip-bundle \
  --skip-listen \
  --skip-spring \
  --skip-turbolinks \
  --skip-coffee

cd ${test_app} && export BUNDLE_GEMFILE=Gemfile

bundle exec rake test
