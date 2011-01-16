require 'support/basic'

module Formtastic
  module Inputs
    module EmailInput
      include Support::Basic
      
      # Outputs a label and a standard Rails email field inside the wrapper.
      def email_input(method, options)
        basic_input_helper(:email_field, :email, method, options)
      end
    end
  end
end