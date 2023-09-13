# frozen_string_literal: true
module Formtastic
  module Inputs
    module Base

      attr_accessor :builder, :template, :object, :object_name, :method, :options

      def initialize(builder, template, object, object_name, method, options)
        @builder = builder
        @template = template
        @object = object
        @object_name = object_name
        @method = method
        @options = options.dup

        # Deprecate :member_label and :member_value, remove v4.0
        member_deprecation_message = "passing an Array of label/value pairs like [['Justin', 2], ['Kate', 3]] into :collection directly (consider building the array in your model using Model.pluck)"
        warn_deprecated_option!(:member_label, member_deprecation_message)
        warn_deprecated_option!(:member_value, member_deprecation_message)
      end

      # Usefull for deprecating options.
      def warn_and_correct_option!(old_option_name, new_option_name)
        if options.key?(old_option_name)
          Deprecation.warn("The :#{old_option_name} option is deprecated in favour of :#{new_option_name} and will be removed from Formtastic in the next version", caller(6))
          options[new_option_name] = options.delete(old_option_name)
        end
      end

      # Usefull for deprecating options.
      def warn_deprecated_option!(old_option_name, instructions)
        if options.key?(old_option_name)
          Deprecation.warn("The :#{old_option_name} option is deprecated in favour of `#{instructions}`. :#{old_option_name} will be removed in the next version", caller(6))
        end
      end

      # Usefull for raising an error on previously supported option.
      def removed_option!(old_option_name)
        raise ArgumentError, ":#{old_option_name} is no longer available" if options.key?(old_option_name)
      end

      extend ActiveSupport::Autoload

      autoload :DatetimePickerish
      autoload :Associations
      autoload :Collections
      autoload :Choices
      autoload :Database
      autoload :Errors
      autoload :Fileish
      autoload :Hints
      autoload :Html
      autoload :Labelling
      autoload :Naming
      autoload :Numeric
      autoload :Options
      autoload :Placeholder
      autoload :Stringish
      autoload :Timeish
      autoload :Validations
      autoload :Wrapping

      include Html
      include Options
      include Database
      include Errors
      include Hints
      include Naming
      include Validations
      include Fileish
      include Associations
      include Labelling
      include Wrapping

    end
  end
end
