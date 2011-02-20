module Formtastic
  module Inputs
    module TimeZoneInput
      # Outputs a timezone select input as Rails' time_zone_select helper. You
      # can give priority zones as option.
      #
      # Examples:
      #
      #   f.input :time_zone, :as => :time_zone, :priority_zones => /Australia/
      def time_zone_input(method, options)
        html_options = options.delete(:input_html) || {}
        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]
        label(method, label_options) <<
        time_zone_select(method, options.delete(:priority_zones),
          strip_formtastic_options(options), html_options)
      end
    end
  end
end