# encoding: utf-8
require 'formtastic/railtie.rb' if defined?(Rails)

module Formtastic
  extend ActiveSupport::Autoload

  autoload :FormBuilder
  autoload :SemanticFormBuilder
  autoload :Helpers
  autoload :HtmlAttributes
  autoload :I18n
  autoload :Inputs
  autoload :LocalizedString
  autoload :Reflection
  autoload :Util
  
  class UnknownInputError < NameError
  end
  
end
