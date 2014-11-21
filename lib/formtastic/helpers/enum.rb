module Formtastic
  module Helpers
    # @private
    module Enum
      # Returns the enum (if defined) for the given method
      def enum_for(method) # @private
        if @object.respond_to?(:defined_enums)
          @object.defined_enums[method.to_s]
        end
      end
    end
  end
end
