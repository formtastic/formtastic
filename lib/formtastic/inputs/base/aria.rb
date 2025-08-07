# frozen_string_literal: true
module Formtastic
  module Inputs
    module Base
      module Aria

        def error_aria_attributes
          return {} unless builder.semantic_errors_link_to_inputs
          return {} unless errors?

          {
            'aria-describedby': describedby,
            'aria-invalid': options.dig(:input_html, :'aria-invalid') || 'true'
          }
        end

        def describedby
          describedby = options.dig(:input_html, :'aria-describedby') || ''
          describedby += ' ' unless describedby.empty?
          describedby += "#{method}_error"
        end

      end
    end
  end
end
