require 'inputs/timeish'

module Formtastic
  module Inputs
    module TimeInput
      include Support::Timeish
      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the time (hour, minute, second).  Each li contains a label
      # (eg "Hour") and a select box. Overwriting the label is possible by adding the :labels option.
      # :labels should be a hash with the field (e.g. day) as key and the label text as value.
      # See date_or_datetime_input for a more detailed output example.
      #
      # Some of Rails' options for select_time are supported, but not everything yet, see
      # documentation of date_or_datetime_input() for more information.
      def time_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options.merge(:discard_year => true, :discard_month => true, :discard_day => true))
      end
    end
  end
end