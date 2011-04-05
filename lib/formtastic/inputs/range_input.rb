module Formtastic
  module Inputs
    class RangeInput
      include Base
      include Base::Stringish

      def to_html
        input_wrapping do
          label_html <<
          builder.range_field(method, input_html_options)
        end
      end
      
      # options[:input_html][:max] trumps :input_html[:max] trumps validations trumps default
      def input_html_options
        input_html_options_from_validations.merge(input_html_options_from_options).merge(super)
      end
      
      def input_html_options_from_options
        hash = {}
        hash[:in] = options[:in] if options.key?(:in)
        hash[:min] = options[:min] if options.key?(:min)
        hash[:max] = options[:max] if options.key?(:max)
        hash[:step] = options[:step] if options.key?(:step)
        hash
      end
      
      def input_html_options_from_validations
        {
          :step => validation_step || 1,
          :min => validation_min || 1,
          :max => validation_max || 100
        }
      end
      
    end
  end
end

