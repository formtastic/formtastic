# encoding: utf-8
$LOAD_PATH << 'lib/formtastic'
require 'active_support/all'
require 'localized_string'
require 'inputs'
require 'helpers'

class MyInput
  include Formtastic::Inputs::Base
end
