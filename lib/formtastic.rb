# encoding: utf-8
# frozen_string_literal: true

module Formtastic
  extend ActiveSupport::Autoload

  autoload :Helpers
  autoload :HtmlAttributes
  autoload :LocalizedString
  autoload :Localizer
  autoload :NamespacedClassFinder
  autoload :InputClassFinder
  autoload :ActionClassFinder
  autoload :Deprecation

  eager_autoload do
    autoload :I18n
    autoload :FormBuilder
    autoload :Inputs
    autoload :Actions
  end

  # @public
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

  # @private
  class UnsupportedEnumCollection < NameError
  end

end

if defined?(::Rails)
  ActiveSupport.on_load(:action_view) do
    include Formtastic::Helpers::FormHelper
  end
end
