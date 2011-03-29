module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    module DatetimeInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Timeish
      def datetime_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options)
      end
    end
  end
end