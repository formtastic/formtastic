module Formtastic
  module Inputs
    module NewBase
      module Timeish
        
        def to_html
          input_wrapping do
            fragments_wrapping do
              fragments_label <<
              template.content_tag(:fieldset,
                template.content_tag(:ol,
                  fragments.map do |fragment|
                    fragment_wrapping do
                      fragment_label_html(fragment) <<
                      fragment_input_html(fragment)
                    end
                  end.join.html_safe # TODO is this safe?
                )
              )
            end
          end
        end
        
        def fragments
          date_fragments + time_fragments
        end
        
        def time_fragments
          options[:include_seconds] ? [:hour, :minute, :second] : [:hour, :minute]
        end
        
        def date_fragments
          options[:order] || i18n_date_fragments || default_date_fragments
        end
        
        def default_date_fragments
          [:year, :month, :day]
        end
        
        def fragment_wrapping(&block)
          template.content_tag(:li, template.capture(&block))
        end
        
        def fragment_label(fragment)
          labels_from_options = options[:labels] || {}
          if labels_from_options.key?(fragment)
            labels_from_options[fragment]
          else
            ::I18n.t(fragment.to_s, :default => fragment.to_s.humanize, :scope => [:datetime, :prompts])
          end
        end
        
        def fragment_id(fragment)
          "#{input_html_options[:id]}_#{position(fragment)}i"
        end
        
        def fragment_name(fragment)
          "#{method}(#{position(fragment)}i)"
        end
        
        def fragment_label_html(fragment)
          text = fragment_label(fragment)
          text.blank? ? "" : template.content_tag(:label, text, :for => fragment_id(fragment))
        end
        
        def value
          object.send(method) if object && object.respond_to?(method)
        end
        
        def fragment_input_html(fragment)
          opts = input_options.merge(:prefix => object_name, :field_name => fragment_name(fragment), :default => value, :include_blank => include_blank?)
          template.send(:"select_#{fragment}", value, opts, input_html_options.merge(:id => fragment_id(fragment)))
        end
        
        # TODO extract to BlankOptions or similar -- Select uses similar code
        def include_blank?
          options.key?(:include_blank) ? options[:include_blank] : builder.include_blank_for_select_by_default
        end
        
        def positions
          { :year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => 6 }
        end
        
        def position(fragment)
          positions[fragment]
        end
        
        def i18n_date_fragments
          order = ::I18n.t(:order, :scope => [:date])
          order = nil unless order.is_a?(Array)
          order
        end
        
        def fragments_wrapping(&block)
          template.content_tag(:fieldset,
            template.capture(&block).html_safe, 
            fragments_wrapping_html_options
          )
        end
        
        def fragments_wrapping_html_options
          {}
        end
        
        def fragments_label
          template.content_tag(:legend, 
            builder.label(method, :for => "#{input_html_options[:id]}_1i"), 
            :class => "label"
          )
        end
        
        def fragments_inner_wrapping(&block)
          template.content_tag(:ol,
            template.capture(&block)
          )
        end
        
      end
    end
  end
end