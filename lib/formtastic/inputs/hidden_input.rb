require 'support/base'

module Formtastic
  module Inputs
    module HiddenInput
      include Support::Base
      
      # Outputs a hidden field inside the wrapper, which should be hidden with CSS.
      # Additionals options can be given using :input_hml. Should :input_html not be
      # specified every option except for formtastic options will be sent straight
      # to hidden input element.
      #
      def hidden_input(method, options)
        options ||= {}
        html_options = options.delete(:input_html) || strip_formtastic_options(options)
        html_options[:id] ||= generate_html_id(method, "")
        hidden_field(method, html_options)
      end
    end
  end
end