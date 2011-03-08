require 'inputs/new_timeish'
require 'inputs/new_base'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DatetimeInput < NewBase
      include NewTimeish

      
    end
  end
end