module Formtastic
  module Inputs
    module RangeInput
      include Formtastic::Inputs::Base
      
      def range_input(method, options)
        basic_input_helper(:range_field, :numeric, method, range_options_for(method, options))
      end
  
    end
  end
end
