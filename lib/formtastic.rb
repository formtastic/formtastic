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
  
  # Deprecate support for Rails < 3.2
  if Util.deprecated_version_of_rails?
    ::ActiveSupport::Deprecation.warn(
      "Support for Rails 3.0 and 3.1 will be dropped from Formtastic 3.0",
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
