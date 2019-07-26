module Formtastic
  module Helpers
    # @private
    module Reflection
      # If an association method is passed in (f.input :author) try to find the
      # reflection object.
      def reflection_for(method) # @private
        if @object.class.respond_to?(:reflect_on_association)
          reflection_on_association @object.class.reflect_on_association(method)
        elsif @object.class.respond_to?(:associations) # MongoMapper uses the 'associations(method)' instead
          reflection_on_association @object.class.associations[method]
        end
      end

      def association_macro_for_method(method) # @private
        reflection = reflection_for(method)
        reflection.macro if reflection
      end

      def association_primary_key_for_method(method) # @private
        reflection = reflection_for(method)
        reflection ? reflection.primary_key(method) : method.to_sym
      end

      private

      def reflection_on_association(reflection)
        return unless reflection

        Formtastic::Reflection.new(reflection)
      end
    end
  end
end