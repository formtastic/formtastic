module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    module TimeInput
      include Formtastic::Inputs::Timeish
      def time_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options.merge(:discard_year => true, :discard_month => true, :discard_day => true))
      end
    end
  end
end