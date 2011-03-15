module Formtastic
  module Inputs
    module NewBase
      module Html
  
        def to_html
          input_wrapping do
            builder.label(method, label_html_options) <<
            builder.text_field(method, input_html_options)
          end
        end
        
        def input_html_options
          opts = options[:input_html] || {}
          opts[:id] ||= input_dom_id
          
          opts
        end
        
        def input_dom_id
          options[:input_html].try(:[], :id) || dom_id
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
          opts[:class] << "required" if required?
          opts[:class] = opts[:class].join(' ')
          
          opts[:id] = wrapper_dom_id
        
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
        
        def hint_html
          if hint?
            template.content_tag(
              :p, 
              Formtastic::Util.html_safe(options[:hint]), 
              :class => (options[:hint_class] || builder.default_hint_class)
            )
          end
        end
        
        def dom_id
          [
            builder.custom_namespace, 
            sanitized_object_name, 
            dom_index, 
            association_primary_key || sanitized_method_name
          ].reject { |x| x.blank? }.join('_')
        end
        
        def wrapper_dom_id
          "#{dom_id.to_s.gsub(association_primary_key.to_s, sanitized_method_name.to_s)}_input"
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
        
      end
    end
  end
end
