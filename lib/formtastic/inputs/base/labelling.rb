module Formtastic
  module Inputs
    module Base
      module Labelling
        
        include Formtastic::LocalizedString
        
        def label_html
          render_label? ? builder.label(input_name, label_text, label_html_options) : "".html_safe
        end
        
        def label_html_options
          # opts = options_for_label(options) # TODO
          opts = {}
          opts[:for] ||= input_html_options[:id]
          opts[:class] = [opts[:class]]
          opts[:class] << 'label'
          
          opts
        end
        
        def label_text
          text  = ((localized_label || humanized_method_name) << requirement_text)
          text %= input_index
          text.html_safe
        end
        
        # TODO: why does this need to be memoized in order to make the inputs_spec tests pass? 
        def requirement_text_or_proc
          @requirement_text_or_proc ||= required? ? builder.required_string : builder.optional_string
        end
        
        def requirement_text
          if requirement_text_or_proc.respond_to?(:call)
            requirement_text_or_proc.call
          else
            requirement_text_or_proc
          end
        end

        def label_from_options
          options[:label]
        end

        def localized_label
          localized_string(method, label_from_options || method, :label)
        end
        
        def render_label?
          return false if options[:label] == false
          true
        end
        
        def input_index
          # Try to get parent builder's @nested_child_index Hash, which contains the current
          # index of the form element we want to look up. Fall back on empty Hash otherwise.
          parent = builder.parent_builder
          duck = parent ? parent.instance_variable_get('@nested_child_index') : {}
          
          # Strip the index from the @nested_child_index, e.g.:
          # `post[comment_attributes][0]` becomes `post[comment_attributes]`
          key = builder.object_name
          key = key.gsub(/\[[0-9]+\]$/, '') if key.is_a?(String)
          
          duck[key].to_i + 1
        end
        
      end
    end
  end
end