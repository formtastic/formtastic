require 'inputs/new_base/timeish'
require 'inputs/new_base'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DatetimeInput 
      include NewBase
      include NewBase::Timeish

      
    end
  end
end