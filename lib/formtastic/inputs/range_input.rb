module Formtastic
  module Inputs
    class RangeInput
      include Base
      include Base::Stringish
      include Helpers::ValidationsHelper

      def to_html
        input_wrapping do
          label_html <<
          builder.range_field(method, range_options_for(method, input_html_options))
        end
      end

    end
  end
end

