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
    
      end
    end
  end
end