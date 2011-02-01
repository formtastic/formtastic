require 'inputs/basic'

module Formtastic
  module Inputs
    module NumericInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Basic
      
      # Outputs a label and standard Rails text field inside the wrapper.
      def numeric_input(method, options)
        basic_input_helper(:number_field, :numeric, method, range_options_for(method, options))
      end
    end
  end
end
