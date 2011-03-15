module Formtastic
  module Inputs
    module NewBase
      module Stringish
        def input_html_options
          super.merge(
            :maxlength => options[:input_html].try(:[], :maxlength) || limit,
            :size => builder.default_text_field_size
          )
        end
      end
    end
  end
end