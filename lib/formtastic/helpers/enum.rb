module Formtastic
  module Helpers
    # @private
    module Enum
      # Returns the enum (if defined) for the given method
      def enum_for(method) # @private        
        @object.defined_enums[method.to_s] if @object.respond_to?(:defined_enums)
      end
    end
  end
end
