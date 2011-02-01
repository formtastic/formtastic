module Formtastic
  module Helpers
    module ValidationHelper
    
      def range_options_for(method, options = {})
        options[:input_html] ||= {}
        if options[:in]
          options[:input_html][:in] = options.delete :in
          options[:input_html][:step] = options.delete :step || 1
          return options
        end
        
        reflections = @object.class.reflect_on_validations_for(method) if @object.class.respond_to? :reflect_on_validations_for
        reflections ||= []
        reflections.each do |reflection|
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
              
            options[:input_html][:in] = (range_start..range_end)
          end
        end
        
        options[:input_html][:step] ||= 1
        
        return options
      end
      
    end
  end
end
