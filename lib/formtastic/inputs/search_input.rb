require 'support/basic'

module Formtastic
  module Inputs
    module SearchInput
      include Support::Basic
      
      # Outputs a label and a standard Rails search field inside the wrapper.
      def search_input(method, options)
        basic_input_helper(:search_field, :search, method, options)
      end
    end
  end
end