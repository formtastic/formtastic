module Formtastic
  module Inputs
    # Outputs a series of select boxes for the fragments that make up a date (year, month, day).
    #
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DateInput 
      include Base
      include Base::Timeish
      
      # We don't want hour and minute fragments on a date input
      def time_fragments
        []
      end
    end
  end
end