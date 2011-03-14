require 'inputs/new_base'
require 'inputs/new_timeish'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DateInput 
      include NewBase
      include NewTimeish
      
      # We don't want hour and minute fragments on a date input
      def time_fragments
        []
      end
    end
  end
end