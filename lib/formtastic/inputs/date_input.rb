require 'inputs/new_base'
require 'inputs/new_timeish'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class DateInput < NewBase
      include NewTimeish
      
      def default_fragments
        [:year, :month, :day]
      end
    end
  end
end