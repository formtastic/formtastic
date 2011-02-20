require 'inputs/timeish'
require 'inputs/base'

module Formtastic
  module Inputs
    module DatetimeInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Timeish
      
      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the date (year, month, day, hour, min, sec).  Each li
      # contains a label (eg "Year") and a select box. Overwriting the label is possible by adding
      # the :labels option. :labels should be a hash with the field (e.g. day) as key and the label
      # text as value.  See date_or_datetime_input for a more detailed output example.
      #
      # Some of Rails' options for select_date are supported, but not everything yet, see
      # documentation of date_or_datetime_input() for more information.
      def datetime_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options)
      end
    end
  end
end