module Formtastic
  module Inputs
    module RangeInput
      include Formtastic::Inputs::Base
      
      def range_input(method, options)  
        reflections = @object.class.reflect_on_validations_for(method) if @object.class.respond_to?(:reflect_on_validations_for)
        reflections.each do |reflection|
          if reflection.macro == :validates_numericality_of
            unless options.include? :in
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
            end
            options[:input_html] ||= {}
            options[:input_html][:in] = options.delete(:in) || (range_start..range_end)
            options[:input_html][:step] = options.delete(:step) || 1
          end
        end
        
        basic_input_helper(:range_field, :numeric, method, options)
      end
  
    end
  end
end
