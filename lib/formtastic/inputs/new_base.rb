module Formtastic
  module Inputs
    class NewBase
      
      attr_accessor :builder, :template, :object, :object_name, :method, :options
      
      def initialize(builder, template, object, object_name, method, options)
        @builder = builder
        @template = template
        @object = object
        @object_name = object_name
        @method = method
        @options = options.dup
      end
      
      def to_html
        input_wrapping do
          builder.label(method, label_html_options) <<
          builder.text_field(method, input_html_options)
        end
      end
      
      def column
        object.column_for_attribute(method) if object.respond_to?(:column_for_attribute)
      end
      
      def column?
        !column.nil?
      end
      
      def column_limit
        column.limit if column?
      end
      
      def limit
        validation_limit || column_limit
      end
      
      
      def input_html_options
        opts = options[:input_html] || {}
        opts[:id] ||= input_dom_id
        
        opts
      end
      
      def input_dom_id
        options[:input_html].try(:[], :id) || dom_id('')
      end
      
      def label_html_options
        # opts = options_for_label(options) # TODO
        opts = {}
        opts[:for] ||= input_dom_id
        
        opts
      end
      
      
      # TODO doesn't cover custom ordering
      def input_wrapping(&block)
        template.content_tag(:li, 
          [template.capture(&block), error_html, hint_html].join("\n").html_safe, 
          wrapper_html_options
        )
      end
      
      
      def wrapper_html_options
        opts = options[:wrapper_html] || {}
        opts[:class] ||= []
        opts[:class] = opts[:class].to_a if opts[:class].is_a?(String)
        opts[:class] << as
        opts[:class] << "error" if errors?
        opts[:class] << "optional" if optional?
        #opts[:class] << "required" if required?
        opts[:class] = opts[:class].join(' ')
        
        opts[:id] = dom_id

        opts
      end
      
      
      
      def error_html
        errors? ? send(:"error_#{builder.inline_errors}_html") : ""
      end
      
      def error_sentence_html
        error_class = options[:error_class] || builder.default_inline_error_class
        template.content_tag(:p, Formtastic::Util.html_safe(errors.to_sentence.html_safe), :class => error_class)
      end
              
      def error_list_html
        error_class = options[:error_class] || builder.default_error_list_class
        list_elements = []
        errors.each do |error|
          list_elements << template.content_tag(:li, Formtastic::Util.html_safe(error.html_safe))
        end
        template.content_tag(:ul, Formtastic::Util.html_safe(list_elements.join("\n")), :class => error_class)
      end

      def error_first_html
        error_class = options[:error_class] || builder.default_inline_error_class
        template.content_tag(:p, Formtastic::Util.html_safe(errors.first.untaint), :class => error_class)
      end
      
      def errors?
        !errors.blank?
      end
      
      def errors
        errors = []
        if object && object.respond_to?(:errors)
          error_keys.each do |key| 
            errors << object.errors[key] unless object.errors[key].blank?
          end
        end
        errors.flatten
      end
      
      def error_keys
        keys = [method.to_sym]
        keys << file_metadata_suffixes.map{|suffix| "#{method}_#{suffix}".to_sym} if file?
        keys << [association_primary_key(method)] if belongs_to?
        keys.flatten.compact.uniq
      end
      
      
      
      
      def hint_html
        if hint?
          template.content_tag(:p, "", :class => "hint")
        end
      end
      
      def hint?
        true
      end
      
      
      def as
        "string" # TODO
      end
              
      def sanitized_object_name
        object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
      end
      
      def sanitized_method_name
        method.to_s.gsub(/[\?\/\-]$/, '')
      end
      
      def attributized_method_name
        method.to_s.gsub(/_id$/, '').to_sym
      end
      
      def dom_id(value='input')
        [
          builder.custom_namespace, 
          sanitized_object_name, 
          dom_index, 
          sanitized_method_name, 
          value
        ].reject { |x| x.blank? }.join('_')
      end
      
      def dom_index
        if options.has_key?(:index)
          options[:index]
        elsif defined?(@auto_index)
          @auto_index
        else
          ""
        end
      end
      
      
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


      
      def file?
        @file ||= begin
          # TODO return true if self.is_a?(Formtastic::Inputs::FileInput::Woo)
          object && object.respond_to?(method) && builder.file_methods.any? { |m| object.send(method).respond_to?(m) }
        end
      end
              





      
      # :belongs_to, etc
      def association
        @association ||= reflection.macro if reflection
      end
      
      def reflection
        @reflection ||= object.class.reflect_on_association(method) if object.class.respond_to?(:reflect_on_association)
      end
      
      def belongs_to?
        association == :belongs_to
      end
      
      
    end
  end
end
  