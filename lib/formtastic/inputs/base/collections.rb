module Formtastic
  module Inputs
    module Base
      module Collections

        def label_method
          @label_method ||= (label_method_from_options || label_and_value_method.first)
        end

        def label_method_from_options
          options[:member_label]
        end

        def value_method
          @value_method ||= (value_method_from_options || label_and_value_method.last)
        end

        def value_method_from_options
          options[:member_value]
        end

        def label_and_value_method
          @label_and_value_method ||= label_and_value_method_from_collection(raw_collection)
        end

        def label_and_value_method_from_collection(_collection)
          sample = _collection.first || _collection.last

          case sample
          when Array
            label, value = :first, :last
          when Integer
            label, value = :to_s, :to_i
          when Symbol, String, NilClass
            label, value = :to_s, :to_s
          end

          # Order of preference: user supplied method, class defaults, auto-detect
          label ||= builder.collection_label_methods.find { |m| sample.respond_to?(m) }
          value ||= builder.collection_value_methods.find { |m| sample.respond_to?(m) }

          [label, value]
        end

        def raw_collection
          @raw_collection ||= (collection_from_options || collection_from_association || collection_for_boolean)
        end

        def collection
          # Return if we have a plain string
          return raw_collection if raw_collection.instance_of?(String) || raw_collection.instance_of?(ActiveSupport::SafeBuffer)

          # Return if we have an Array of strings, fixnums or arrays
          return raw_collection if (raw_collection.instance_of?(Array) || raw_collection.instance_of?(Range)) &&
                               [Array, Fixnum, String].include?(raw_collection.first.class) &&
                               !(options.include?(:member_label) || options.include?(:member_value))

          raw_collection.map { |o| [send_or_call(label_method, o), send_or_call(value_method, o)] }
        end

        def collection_from_options
          items = options[:collection]
          case items
          when Hash
            items.to_a
          when Range
            items.to_a.collect{ |c| [c.to_s, c] }
          else
            items
          end
        end

        def collection_from_association
          if reflection
            if reflection_options? && reflection.options[:polymorphic] == true
              raise PolymorphicInputWithoutCollectionError.new(
                "A collection must be supplied for #{method} input. Collections cannot be guessed for polymorphic associations."
              )
            end
            reflection.klass.where(conditions_from_scope)
          end
        end
        
        def conditions_from_reflection
          conditions = (reflection_options? && reflection.options[:conditions]) || {}
          return conditions.call if conditions.is_a?(Proc)
          return conditions
        end
        
        def conditions_from_scope
          conditions_from_reflection.empty? ? nil : {:conditions => conditions_from_reflection}
        end
        
        def collection_for_boolean
          true_text = options[:true] || Formtastic::I18n.t(:yes)
          false_text = options[:false] || Formtastic::I18n.t(:no)

          # TODO options[:value_as_class] = true unless options.key?(:value_as_class)

          [ [true_text, true], [false_text, false] ]
        end

        def send_or_call(duck, object)
          if duck.respond_to?(:call)
            duck.call(object)
          elsif object.respond_to? duck.to_sym
            object.send(duck)
          end
        end

        # Avoids an issue where `send_or_call` can be a String and duck can be something simple like
        # `:first`, which obviously String responds to.
        def send_or_call_or_object(duck, object)
          return object if object.is_a?(String) || object.is_a?(Integer) # TODO what about other classes etc?
          send_or_call(duck, object)
        end

      end
    end
  end
end
