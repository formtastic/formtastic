require 'inputs/basic'

module Formtastic
  module Inputs
    module TextInput
      include Support::Basic
      
      # Ouputs a label and standard Rails text area inside the wrapper.
      def text_input(method, options)
        basic_input_helper(:text_area, :text, method, options)
      end
    end
  end
end