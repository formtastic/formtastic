module Formtastic
  module Inputs
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