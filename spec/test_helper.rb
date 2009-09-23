# coding: utf-8
require 'rubygems'

# To get the specs to run on Ruby 1.9.x.
gem 'test-unit',                  '= 1.2.3'
gem 'activesupport',              '>= 2.3.3'
gem 'actionpack',                 '>= 2.3.3'
gem 'rspec',                      '>= 1.2.6'
gem 'rspec-rails',                '>= 1.2.6'
gem 'rspec_hpricot_matchers',     '>= 1.0.0'
gem 'hpricot',                    '>= 0.6.1'

require 'spec'
require 'activesupport'
require 'actionpack'
require 'active_support'
require 'action_controller'
require 'action_view'
require 'rexml/document'
require 'rspec_hpricot_matchers'

Spec::Runner.configure do |config|
  config.include(RspecHpricotMatchers)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
