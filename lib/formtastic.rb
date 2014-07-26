# encoding: utf-8
require 'formtastic/engine' if defined?(::Rails)

module Formtastic
  extend ActiveSupport::Autoload

  autoload :FormBuilder
  autoload :Helpers
  autoload :HtmlAttributes
  autoload :I18n
  autoload :Inputs
  autoload :Actions
  autoload :LocalizedString
  autoload :Localizer
  autoload :Util
  
  if defined?(::Rails) && Util.deprecated_version_of_rails?
    ::ActiveSupport::Deprecation.warn(
      "Support for Rails < 4.0.4 will be dropped from Formtastic 4.0",
      caller)
  end

  # @private
  class UnknownInputError < NameError
  end
  
  # @private
  class UnknownActionError < NameError
  end
  
  # @private
  class PolymorphicInputWithoutCollectionError < ArgumentError
  end
  
  # @private
  class UnsupportedMethodForAction < ArgumentError
  end

end
