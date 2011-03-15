require 'inputs/new_base'
require 'inputs/timeish'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DateInput 
      include NewBase
      include Timeish
      
      # We don't want hour and minute fragments on a date input
      def time_fragments
        []
      end
    end
  end
end