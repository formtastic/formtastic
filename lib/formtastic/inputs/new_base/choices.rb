module Formtastic
  module Inputs
    module NewBase
      module Choices
        
        def choices_wrapping(&block)
          template.content_tag(:fieldset, 
            template.capture(&block),
            choices_wrapping_html_options
          )
        end

        def choices_wrapping_html_options
          {}
        end

        def choices_group_wrapping(&block)
          template.content_tag(:ol, 
            template.capture(&block),
            choices_group_wrapping_html_options
          )
        end

        def choices_group_wrapping_html_options
          {}
        end

        def choice_wrapping(html_options, &block)
          template.content_tag(:li, 
            template.capture(&block),
            html_options
          )
        end

        def choice_wrapping_html_options(choice)
          { :class => value_as_class? ? "#{sanitized_method_name.singularize}_#{choice_html_safe_value(choice)}" : '' }
        end

        def choice_html(choice)        
          template.content_tag(:label,
            hidden_fields? ? 
              check_box_with_hidden_input(choice) : 
              check_box_without_hidden_input(choice) <<
            choice_label(choice),
            label_html_options.merge(:for => choice_input_dom_id(choice))
          )
        end

        def choice_label(choice)
          choice.is_a?(Array) ? choice.first : choice
        end

        def choice_value(choice)
          choice.is_a?(Array) ? choice.last : choice
        end

        def choice_html_safe_value(choice)
          choice_value(choice).to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase
        end

        def choice_input_dom_id(choice)
          [
            builder.custom_namespace,
            sanitized_object_name,
            association_primary_key || method,
            choice_html_safe_value(choice)
          ].compact.reject { |i| i.blank? }.join("_")
        end
        
      end
    end
  end
end