module Formtastic
  module Inputs
    module NewBase
      module Validations

        def validations
          if object && object.class.respond_to?(:validators_on) 
            object.class.validators_on(attributized_method_name).select do |validator|
              validator_relevant?(validator)
            end
          else
            []
          end
        end
        
        def validator_relevant?(validator)
          return true unless validator.options.key?(:if) || validator.options.key?(:unless)
          conditional = validator.options[:if] || validator.options[:unless]
          
          result = if conditional.respond_to?(:call)
            conditional.call(object)
          elsif conditional.is_a?(::Symbol) && object.respond_to?(conditional)
            object.send(conditional)
          else
            conditional
          end
          
          validator.options.key?(:unless) ? !result : !!result
        end
        
        def validation_limit
          validation = validations? && validations.find do |validation|
            validation.kind == :length
          end
          if validation
            validation.options[:maximum] || (validation.options[:within].present? ? validation.options[:within].max : nil)
          else
            nil
          end
        end
        
        def validations?
          !validations.empty?
        end
        
        def required?
          if validations?
            !validations.find { |validator| [:presence, :inclusion, :length].include?(validator.kind) }.nil?
          else
            builder.all_fields_required_by_default
          end
        end
        
        def optional?
          !required?
        end
        
        def column_limit
          column.limit if column?
        end
        
        def limit
          validation_limit || column_limit
        end
        
      end
    end
  end
end
        
        