module Formtastic
  module Inputs
    module Base
      module Collections

        def label_method
          label_and_value_method(raw_collection).first
        end

        def value_method
          label_and_value_method(raw_collection).last
        end

        def label_and_value_method(_collection, grouped=false)
          sample = _collection.first || _collection.last

          case sample
          when Array
            label, value = :first, :last
          when Integer
            label, value = :to_s, :to_i
          when String, NilClass
            label, value = :to_s, :to_s
          end

          # Order of preference: user supplied method, class defaults, auto-detect
          label = (grouped ? options[:grouped_label_method] : options[:member_label]) || label || builder.collection_label_methods.find { |m| sample.respond_to?(m) }
          value = (grouped ? options[:grouped_value_method] : options[:member_value]) || value || builder.collection_value_methods.find { |m| sample.respond_to?(m) }

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
                               [Array, Fixnum, String, Symbol].include?(raw_collection.first.class) &&
                               !(options.include?(:member_label) || options.include?(:member_value))

          raw_collection.map { |o| [send_or_call(label_method, o), send_or_call(value_method, o)] }
        end

        def collection_from_options
          items = options[:collection]
          items = items.to_a if items.is_a?(Hash)
          items
        end

        def collection_from_association
          if reflection
            raise PolymorphicInputWithoutCollectionError.new("A collection must be supplied for #{method} input. Collections cannot be guessed for polymorphic associations.") if reflection.options && reflection.options[:polymorphic] == true

            find_options_from_options = options[:find_options] || {}
            conditions_from_options = find_options_from_options[:conditions] || {}
            conditions_from_reflection = reflection.options && reflection.options[:conditions] || {}
            conditions_from_reflection = conditions_from_reflection.call if conditions_from_reflection.is_a?(Proc)

            if conditions_from_options.any?
              reflection.klass.scoped(:conditions => conditions_from_reflection).where(conditions_from_options)
            else
              find_options_from_options.merge!(:include => group_by) if self.respond_to?(:group_by) && group_by
              reflection.klass.scoped(:conditions => conditions_from_reflection).where(find_options_from_options)
            end
          end
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
          return object if object.is_a?(String) # TODO what about other classes etc?
          send_or_call(duck, object)
        end

      end
    end
  end
end
