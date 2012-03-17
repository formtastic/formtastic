module Formtastic
  module Inputs
    module Base
      # @todo relies on `dom_id`, `required?`, `optional`, `errors?`, `association_primary_key` & `sanitized_method_name` methods from another module
      module Wrapping
        
        # Override this method if you want to change the display order (for example, rendering the
        # errors before the body of the input).
        def input_wrapping(&block)
          template.content_tag(:li, 
            [template.capture(&block), error_html, hint_html].join("\n").html_safe, 
            wrapper_html_options
          )
        end
        
        def wrapper_html_options
          opts = wrapper_html_options_raw
          opts[:class] = wrapper_classes
          opts[:id] ||= wrapper_dom_id 
          opts
        end
        
        def wrapper_html_options_raw
          (options[:wrapper_html] || {}).dup
        end
        
        def wrapper_classes_raw
          classes = wrapper_html_options_raw[:class] || []
          return classes.dup if classes.is_a?(Array)
          return [classes]
        end
        
        def wrapper_classes
          classes = wrapper_classes_raw
          classes << as
          classes << "input"
          classes << "error" if errors?
          classes << "optional" if optional?
          classes << "required" if required?
          classes << "autofocus" if autofocus?

          classes.join(' ')
        end
        
        def wrapper_dom_id
          @wrapper_dom_id ||= "#{dom_id.to_s.gsub((association_primary_key || method).to_s, sanitized_method_name.to_s)}_input"
        end
                
      end
    end
  end
end
