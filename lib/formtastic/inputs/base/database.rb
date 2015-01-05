module Formtastic
  module Inputs
    module Base
      module Database
        
        def column
          if object.respond_to?(:column_for_attribute)
            # Remove deprecation wrapper & review after Rails 5.0 ships
            ActiveSupport::Deprecation.silence do
              object.column_for_attribute(method)
            end
          end
        end
        
        def column?
          !column.nil?
        end
        
      end
    end
  end
end
