require 'inputs/timeish'
require 'inputs/new_base'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DatetimeInput 
      include NewBase
      include Timeish

      
    end
  end
end