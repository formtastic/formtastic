# encoding: utf-8
require 'formtastic/railtie' if defined?(::Rails)
require 'formtastic/engine' if defined?(::Rails)

module Formtastic
  extend ActiveSupport::Autoload

  autoload :FormBuilder
  autoload :SemanticFormBuilder
  autoload :Helpers
  autoload :HtmlAttributes
  autoload :I18n
  autoload :Inputs
  autoload :LocalizedString
  autoload :Util
  
  # @private
  class UnknownInputError < NameError
  end
  
  # @private
  class PolymorphicInputWithoutCollectionError < ArgumentError
  end
  
end
