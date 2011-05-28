module Formtastic
  module Inputs
    # Alias for NumberInput for backwards compatibility with 1.x.
    # 
    # @example:
    #   f.input :age, :as => :numeric
    #
    # @deprecated Use :as => :number instead
    #
    # @todo Remove on or after 2.1
    class NumericInput < NumberInput
      
      def initialize(builder, template, object, object_name, method, options)
        ActiveSupport::Deprecation.warn(':as => :numeric has been deprecated in favor of :as => :number and will be removed on or after version 2.1', caller)
        super
      end
      
    end
  end
end

