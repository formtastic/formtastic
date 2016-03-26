module Formtastic
  module Inputs
    module Base
      module Validations

        class IndeterminableMinimumAttributeError < ArgumentError
          def message
            [
              "A minimum value can not be determined when the validation uses :greater_than on a :decimal or :float column type.",
              "Please alter the validation to use :greater_than_or_equal_to, or provide a value for this attribute explicitly with the :min option on input()."
            ].join("\n")
          end
        end

        class IndeterminableMaximumAttributeError < ArgumentError
          def message
            [
              "A maximum value can not be determined when the validation uses :less_than on a :decimal or :float column type.",
              "Please alter the validation to use :less_than_or_equal_to, or provide a value for this attribute explicitly with the :max option on input()."
            ].join("\n")
          end
        end

        def validations
          @validations ||= if object && object.class.respond_to?(:validators_on)
            object.class.validators_on(attributized_method_name).select do |validator|
              validator_relevant?(validator)
            end
          else
            nil
          end
        end

        def validator_relevant?(validator)
          return true unless validator.options.key?(:if) || validator.options.key?(:unless)
          conditional = validator.options.key?(:if) ? validator.options[:if] : validator.options[:unless]

          result = if conditional.respond_to?(:call) && conditional.arity > 0
            conditional.call(object)
          elsif conditional.respond_to?(:call) && conditional.arity == 0
            object.instance_exec(&conditional)
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

        # Prefer :greater_than_or_equal_to over :greater_than, for no particular reason.
        def validation_min
          validation = validations? && validations.find do |validation|
            validation.kind == :numericality
          end

          if validation
            # We can't determine an appropriate value for :greater_than with a float/decimal column
            raise IndeterminableMinimumAttributeError if validation.options[:greater_than] && column? && [:float, :decimal].include?(column.type)

            if validation.options[:greater_than_or_equal_to]
              return (validation.options[:greater_than_or_equal_to].call(object)) if validation.options[:greater_than_or_equal_to].kind_of?(Proc)
              return (validation.options[:greater_than_or_equal_to])
            end

            if validation.options[:greater_than]
              return (validation.options[:greater_than].call(object) + 1) if validation.options[:greater_than].kind_of?(Proc)
              return (validation.options[:greater_than] + 1)
            end
          end
        end

        # Prefer :less_than_or_equal_to over :less_than, for no particular reason.
        def validation_max
          validation = validations? && validations.find do |validation|
            validation.kind == :numericality
          end
          if validation
            # We can't determine an appropriate value for :greater_than with a float/decimal column
            raise IndeterminableMaximumAttributeError if validation.options[:less_than] && column? && [:float, :decimal].include?(column.type)

            if validation.options[:less_than_or_equal_to]
              return (validation.options[:less_than_or_equal_to].call(object)) if validation.options[:less_than_or_equal_to].kind_of?(Proc)
              return (validation.options[:less_than_or_equal_to])
            end

            if validation.options[:less_than]
              return ((validation.options[:less_than].call(object)) - 1) if validation.options[:less_than].kind_of?(Proc)
              return (validation.options[:less_than] - 1)
            end
          end
        end

        def validation_step
          validation = validations? && validations.find do |validation|
            validation.kind == :numericality
          end
          if validation
            validation.options[:step] || (1 if validation_integer_only?)
          else
            nil
          end
        end

        def validation_integer_only?
          validation = validations? && validations.find do |validation|
            validation.kind == :numericality
          end
          if validation
            validation.options[:only_integer]
          else
            false
          end
        end

        def validations?
          validations != nil
        end

        def required?
          return false if options[:required] == false
          return true if options[:required] == true
          return false if not_required_through_negated_validation?
          if validations?
            validations.any? { |validator|
              if validator.options.key?(:on)
                validator_on = Array(validator.options[:on])
                next false if (validator_on.exclude?(:save)) && ((object.new_record? && validator_on.exclude?(:create)) || (!object.new_record? && validator_on.exclude?(:update)))
              end
              case validator.kind
              when :presence
                true
              when :inclusion
                validator.options[:allow_blank] != true
              when :length
                validator.options[:allow_blank] != true &&
                validator.options[:minimum].to_i > 0 ||
                validator.options[:within].try(:first).to_i > 0
              else
                false
              end
            }
          else
            return responds_to_global_required? && !!builder.all_fields_required_by_default
          end
        end

        def required_attribute?
          required? && builder.use_required_attribute
        end

        def not_required_through_negated_validation?
          @not_required_through_negated_validation
        end

        def not_required_through_negated_validation!
          @not_required_through_negated_validation = true
        end

        def responds_to_global_required?
          true
        end

        def optional?
          !required?
        end

        def autofocus?
          opt_autofocus = options[:input_html] && options[:input_html][:autofocus]

          !!opt_autofocus
        end

        def column_limit
          column.limit if column? && column.respond_to?(:limit)
        end

        def limit
          validation_limit || column_limit
        end

        def readonly?
          readonly_from_options? || readonly_attribute?
        end

        def readonly_attribute?
          object_class = self.object.class
          object_class.respond_to?(:readonly_attributes) &&
            self.object.persisted? &&
            column.respond_to?(:name) &&
            object_class.readonly_attributes.include?(column.name.to_s)
        end

        def readonly_from_options?
          options[:input_html] && options[:input_html][:readonly]
        end
      end
    end
  end
end

