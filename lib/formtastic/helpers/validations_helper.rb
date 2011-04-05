module Formtastic
  module Helpers
    module ValidationsHelper

      def range_options_for(method, options = {})
        if options[:in]
          options[:step] = options.delete :step || 1
          return options
        end

        reflections = @object.class.reflect_on_validations_for(method) if @object.class.respond_to? :reflect_on_validations_for
        reflections ||= []
        reflections.each do |reflection|
          p reflection.macro
          if reflection.macro == :validates_numericality_of
            if reflection.options.include?(:greater_than)
              range_start = (reflection.options[:greater_than] + 1)
            elsif reflection.options.include?(:greater_than_or_equal_to)
              range_start = reflection.options[:greater_than_or_equal_to]
            end
            if reflection.options.include?(:less_than)
              range_end = (reflection.options[:less_than] - 1)
            elsif reflection.options.include?(:less_than_or_equal_to)
              range_end = reflection.options[:less_than_or_equal_to]
            end

            # This ensures proper and default range,
            # even if programmer has not entered any details for the macro
            range_start ||= 0
            range_end ||= 100

            # When using macro `:validates_numericality_of`, you can
            # use `:step` option to pre-define step for numeric fields.
            # However, this is non-standard option for ActiveModel.
            options[:step] = (reflection.options[:step] || 1)

            options[:in] = (range_start..range_end)
          end
        end

        return options
      end

    end
  end
end

