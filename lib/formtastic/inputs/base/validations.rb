module Formtastic
  module Inputs
    module Base
      module Validations
        
        def validations
          @validations ||= if object && object.class.respond_to?(:validators_on) 
            object.class.validators_on(attributized_method_name).select do |validator|
              validator_relevant?(validator)
            end
          else
            []
          end
        end
        
        def validator_relevant?(validator)
          return true unless validator.options.key?(:if) || validator.options.key?(:unless)
          conditional = validator.options.key?(:if) ? validator.options[:if] : validator.options[:unless]
          
          result = if conditional.respond_to?(:call)
            conditional.call(object)
          elsif conditional.is_a?(::Symbol) && object.respond_to?(conditional)
            object.send(conditional)
          else
            conditional
          end
          
          result = validator.options.key?(:unless) ? !result : !!result
          not_required_through_negated_validation! if !result && [:presence, :inclusion, :length].include?(validator.kind)

          result
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
          return false if not_required_through_negated_validation?
          if validations?
            validations.select { |validator| 
              [:presence, :inclusion, :length].include?(validator.kind) &&
              validator.options[:allow_blank] != true
            }.any?
          else
            return false if options[:required] == false
            return true if options[:required] == true
            return !!builder.all_fields_required_by_default
          end
        end
        
        def not_required_through_negated_validation?
          @not_required_through_negated_validation
        end
        
        def not_required_through_negated_validation!
          @not_required_through_negated_validation = true
        end
        
        def optional?
          !required?
        end
        
        def column_limit
          column.limit if column? && column.respond_to?(:limit)
        end
        
        def limit
          validation_limit || column_limit
        end
        
      end
    end
  end
end
        
        