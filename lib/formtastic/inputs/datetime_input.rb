module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DatetimeInput 
      include Base
      include Base::Timeish
    end
  end
end