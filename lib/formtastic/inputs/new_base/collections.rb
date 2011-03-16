module Formtastic
  module Inputs
    module NewBase
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
          label = (grouped ? options[:grouped_label_method] : options[:label_method]) || label || builder.collection_label_methods.find { |m| sample.respond_to?(m) }
          value = (grouped ? options[:grouped_value_method] : options[:value_method]) || value || builder.collection_value_methods.find { |m| sample.respond_to?(m) }
      
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
                               !(options.include?(:label_method) || options.include?(:value_method))
                       
          raw_collection.map { |o| [send_or_call(label_method, o), send_or_call(value_method, o)] }
        end
      
        def collection_from_options
          items = options[:collection]
          items = items.to_a if items.is_a?(Hash)
          items
        end
      
        def collection_from_association
          if reflection
            find_options_from_options = options[:find_options] || {}
            conditions_from_options = find_options_from_options[:conditions] || {}
            conditions_from_reflection = reflection.options[:conditions] || {}
            
            if conditions_from_options.any?
              reflection.klass.where(
                conditions_from_reflection.merge(conditions_from_options)
              )
            else
              find_options_from_options.merge!(:include => group_by) if group_by
              reflection.klass.where(conditions_from_reflection.merge(find_options_from_options))
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
          if duck.is_a?(Proc)
            duck.call(object)
          else
            object.send(duck)
          end
        end
      
        # TODO this seems to overlap or be confused with association_primary_key
        def input_name
          if reflection
            if [:has_and_belongs_to_many, :has_many].include?(reflection.macro)
              "#{method.to_s.singularize}_ids"
            elsif reflection.respond_to? :foreign_key
              reflection.foreign_key
            else
              reflection.options[:foreign_key] || "#{method}_id"
            end
          else
            method
          end.to_sym
        end

      end
    end
  end
end