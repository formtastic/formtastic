module Formtastic
  module Inputs
    module RangeInput
      include Formtastic::Inputs::Base
      
      def range_input(method, options)  
        options[:input_html] ||= {}
        options[:input_html][:in] = options.delete(:in)
        options[:input_html][:step] = options.delete(:step) || 1
        
        unless options[:input_html][:in]
          reflections = @object.class.reflect_on_validations_for(method) rescue []
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
        end
        
        basic_input_helper(:range_field, :numeric, method, options)
      end
  
    end
  end
end
