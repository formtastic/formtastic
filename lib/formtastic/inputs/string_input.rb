require 'inputs/basic'

module Formtastic
  module Inputs
    module StringInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Basic
      # Outputs a label and standard Rails text field inside the wrapper.
      def string_input(method, options)
        basic_input_helper(:text_field, :string, method, options)
      end
    end
  end
end