module Formtastic
  module Inputs
    class IconishSegmentsInput
      include Base
      include Base::Stringish

      def to_html
        input_wrapping do
          label_html <<
          iconish_segments_controls
        end
      end

      def iconish_segments_controls
        iconish_segments_wrapping do
          builder.text_field(method, input_html_options)
        end
      end

      def iconish_segments_wrapping(&block)
        template.content_tag(:div,
                             iconish_segments(&block),
                             iconish_segments_wrapping_html_options
        )
      end

      def iconish_segments(&block)
        [add_on_prepend, template.capture(&block), add_on_append].compact.join("\n").html_safe
      end

      def iconish_segments_wrapping_html_options
        {:class => iconish_segments_wrapping_classes}
      end

      def iconish_segments_wrapping_classes
        opt = options
        classes = ['iconish-segments-controls']
        classes << 'input-prepend' if opt[:input_prepend]
        classes << 'input-append' if opt[:input_append]
        classes.join(' ')
      end

      def add_on_prepend
        add_on_from_options(:input_prepend)
      end

      def add_on_append
        add_on_from_options(:input_append)
      end

      def add_on_from_options(key)
        if opt = options[key]
          content = if opt.is_a?(Proc)
                      opt.call
                    else
                      opt.to_s
                    end
          add_on(content)
        end
      end

      def add_on(content)
        if content =~ /^<button.*>/
          content
        else
          template.content_tag(:span, content, :class => 'add-on')
        end
      end
    end

  end
end
