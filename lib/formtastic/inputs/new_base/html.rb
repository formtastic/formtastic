module Formtastic
  module Inputs
    module NewBase
      module Html
  
        def to_html
          input_wrapping do
            label_html <<
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
        
        def hint_html
          if hint?
            template.content_tag(
              :p, 
              Formtastic::Util.html_safe(hint_text), 
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
        
        def dom_index
          if builder.options.has_key?(:index)
            builder.options[:index]
          elsif !builder.auto_index.blank?
            # TODO there's no coverage for this case, not sure how to create a scenario for it
            builder.auto_index
          else
            ""
          end
        end
        
      end
    end
  end
end
