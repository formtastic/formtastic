#!/usr/bin/env sh

set -e
set -o verbose

test_app=dummy
rm -rf ${test_app}

export RAILS_INTEGRATION_VERSION="8.0.2"
gem install rails -v ${RAILS_INTEGRATION_VERSION}
rails -v

rails new ${test_app} \
  --template=$(dirname "$0")/integration-template.rb \
  --skip-bootsnap \
  --skip-javascript \
  --skip-spring \
  --skip-turbolinks \
  --skip-kamal

cd ${test_app}

bundle add formtastic --path=../formtastic
bundle install
bundle exec rake test
