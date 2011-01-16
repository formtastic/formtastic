module Formtastic
  module Inputs
    module Support
      module Basic
        def basic_input_helper(form_helper_method, type, method, options) #:nodoc:
          html_options = options.delete(:input_html) || {}
          html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text, :phone, :search, :url, :email].include?(type)
          field_id = generate_html_id(method, "")
          html_options[:id] ||= field_id
          label_options = options_for_label(options)
          label_options[:for] ||= html_options[:id]
          label(method, label_options) <<
            send(respond_to?(form_helper_method) ? form_helper_method : :text_field, method, html_options)
        end
      end
    end
  end
end