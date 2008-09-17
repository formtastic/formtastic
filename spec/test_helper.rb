require 'rubygems'
require 'spec'
require 'activesupport'
require 'active_support'
require 'actionpack'
require 'action_controller'
require 'action_view'
require 'rexml/document'
require File.dirname(__FILE__) + '/xpath_matchers'
require 'rspec_hpricot_matchers'
Spec::Runner.configure do |config|
  config.include(RspecHpricotMatchers)
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/../lib')
