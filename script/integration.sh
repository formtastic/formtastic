#!/usr/bin/env sh

set -e
set -o verbose

test_app=dummy
rm -rf ${test_app}
mkdir ${test_app}
cd ${test_app}
echo "source 'https://rubygems.org'" > Gemfile

# If 'edge' then use main
if [ "$RAILS_VERSION" = "edge" ]; then
  echo "gem 'rails', git: 'https://github.com/rails/rails.git', branch: 'main'" >> Gemfile
else
  echo "gem 'rails', '~> $RAILS_VERSION'" >> Gemfile
fi

bundle install
bundle exec rails new test_app \
  --template=../script/integration-template.rb \
  --skip-bootsnap \
  --skip-javascript \
  --skip-spring \
  --skip-turbolinks

cd test_app

bundle exec rake test
