module Formtastic
  module Inputs
    module UrlInput
      include Formtastic::Inputs::Basic
      
      # Outputs a label and a standard Rails url field inside the wrapper.
      def url_input(method, options)
        basic_input_helper(:url_field, :url, method, options)
      end
    end
  end
end