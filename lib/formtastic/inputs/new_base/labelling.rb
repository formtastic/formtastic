module Formtastic
  module Inputs
    module NewBase
      module Labelling
        
        include Formtastic::LocalizedString
        
        def label_text
          ((localized_label || humanized_method_name) << required_or_optional_string).html_safe
        end

        def required_or_optional_string
          case required?
            when true then builder.required_string.call
            when false then builder.optional_string.call
            else options[:required] # TODO why?
          end
        end

        def label_from_options
          options[:label]
        end

        def localized_label
          localized_string(method, label_from_options, :label)
        end
        
        def render_label?
          return false if options[:label] == false
          true
        end
        
      end
    end
  end
end