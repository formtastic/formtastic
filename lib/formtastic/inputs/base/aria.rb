# frozen_string_literal: true
module Formtastic
  module Inputs
    module Base
      module Aria

        def default_aria_attributes
          return {} unless builder.semantic_errors_link_to_inputs
          return {} unless errors?

          {
            'aria-describedby': "#{method}_error",
            'aria-invalid': 'true'
          }
        end

      end
    end
  end
end
