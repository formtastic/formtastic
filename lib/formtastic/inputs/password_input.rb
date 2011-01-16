require 'support/basic'

module Formtastic
  module Inputs
    module PasswordInput
      include Support::Basic
      
      # Outputs a label and standard Rails password field inside the wrapper.
      def password_input(method, options)
        basic_input_helper(:password_field, :password, method, options)
      end
    end
  end
end