module Formtastic
  module Inputs
    module Support
      module Base

        def set_include_blank(options)
          unless options.key?(:include_blank) || options.key?(:prompt)
            options[:include_blank] = include_blank_for_select_by_default
          end
          options
        end
        
        def escape_html_entities(string) #:nodoc:
          if escape_html_entities_in_hints_and_labels
            # Acceppt html_safe flag as indicator to skip escaping
            string = template.escape_once(string) unless string.respond_to?(:html_safe?) && string.html_safe? == true
          end
          string
        end
        
        # Prepare options to be sent to label
        def options_for_label(options) #:nodoc:
          options.slice(:label, :required).merge!(options.fetch(:label_html, {}))
        end
        
        # Remove any Formtastic-specific options before passing the down options.
        def strip_formtastic_options(options) #:nodoc:
          options.except(:value_method, :label_method, :collection, :required, :label,
                         :as, :hint, :input_html, :label_html, :value_as_class, :find_options, :class)
        end
        
        # Generates the legend for radiobuttons and checkboxes
        def legend_tag(method, options = {})
          if options[:label] == false
            Formtastic::Util.html_safe("")
          else
            text = localized_string(method, options[:label], :label) || humanized_attribute_name(method)
            text += required_or_optional_string(options.delete(:required))
            text = Formtastic::Util.html_safe(text)
            template.content_tag :legend, template.label_tag(nil, text, :for => nil), :class => :label
          end
        end
        
        # Used by select and radio inputs. The collection can be retrieved by
        # three ways:
        #
        # * Explicitly provided through :collection
        # * Retrivied through an association
        # * Or a boolean column, which will generate a localized { "Yes" => true, "No" => false } hash.
        #
        # If the collection is not a hash or an array of strings, fixnums or arrays,
        # we use label_method and value_method to retreive an array with the
        # appropriate label and value.
        #
        def find_collection_for_column(column, options) #:nodoc:
          collection = find_raw_collection_for_column(column, options)
    
          # Return if we have a plain string
          return collection if collection.instance_of?(String) || collection.instance_of?(::Formtastic::Util.rails_safe_buffer_class)
    
          # Return if we have an Array of strings, fixnums or arrays
          return collection if (collection.instance_of?(Array) || collection.instance_of?(Range)) &&
                               [Array, Fixnum, String, Symbol].include?(collection.first.class) &&
                               !(options.include?(:label_method) || options.include?(:value_method))
    
          label, value = detect_label_and_value_method!(collection, options)
          collection.map { |o| [send_or_call(label, o), send_or_call(value, o)] }
        end
        
        # Detects the label and value methods from a collection using methods set in
        # collection_label_methods and collection_value_methods. For some ruby core
        # classes sensible defaults have been defined. It will use and delete the options
        # :label_method and :value_methods when present.
        #
        def detect_label_and_value_method!(collection, options = {})
          sample = collection.first || collection.last
    
          case sample
          when Array
            label, value = :first, :last
          when Integer
            label, value = :to_s, :to_i
          when String, NilClass
            label, value = :to_s, :to_s
          end
    
          # Order of preference: user supplied method, class defaults, auto-detect
          label = options[:label_method] || label || collection_label_methods.find { |m| sample.respond_to?(m) }
          value = options[:value_method] || value || collection_value_methods.find { |m| sample.respond_to?(m) }
    
          [label, value]
        end
        
        # Used by association inputs (select, radio) to generate the name that should
        # be used for the input
        #
        #   belongs_to :author; f.input :author; will generate 'author_id'
        #   belongs_to :entity, :foreign_key = :owner_id; f.input :author; will generate 'owner_id'
        #   has_many :authors; f.input :authors; will generate 'author_ids'
        #   has_and_belongs_to_many will act like has_many
        #
        def generate_association_input_name(method) #:nodoc:
          if reflection = reflection_for(method)
            if [:has_and_belongs_to_many, :has_many].include?(reflection.macro)
              "#{method.to_s.singularize}_ids"
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