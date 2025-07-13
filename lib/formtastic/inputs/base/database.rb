# frozen_string_literal: true
module Formtastic
  module Inputs
    module Base
      module Database

        def column
          if object.respond_to?(:column_for_attribute)
            object.column_for_attribute(method)
          end
        end

        def column?
          !column.nil?
        end

      end
    end
  end
end
