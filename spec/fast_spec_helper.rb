# encoding: utf-8
$LOAD_PATH << 'lib/formtastic'
require 'active_support/all'
require 'localized_string'
require 'inputs'
require 'helpers'

class MyInput
  include Formtastic::Inputs::Base
end

I18n.enforce_available_locales = false if I18n.respond_to?(:enforce_available_locales)
