#!/usr/bin/env sh

set -e
set -o verbose

test_app=dummy
rm -rf ${test_app}

export RAILS_INTEGRATION_VERSION="8.1.1"
gem install rails -v ${RAILS_INTEGRATION_VERSION}
rails -v

rails new ${test_app} \
  --template=$(dirname "$0")/integration-template.rb \
  --skip-bootsnap \
  --skip-brakeman \
  --skip-bundler-audit \
  --skip-ci \
  --skip-git \
  --skip-javascript \
  --skip-jbuilder \
  --skip-kamal \
  --skip-rubocop \
  --skip-solid \
  --skip-spring \
  --skip-thruster

cd ${test_app}

bundle add formtastic --path=../formtastic
bundle install
bundle exec rake test
