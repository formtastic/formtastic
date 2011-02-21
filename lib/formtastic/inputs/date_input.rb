require 'inputs/timeish'
require 'inputs/base'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    module DateInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Timeish
      def date_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options.merge(:discard_hour => true))
      end
    end
  end
end