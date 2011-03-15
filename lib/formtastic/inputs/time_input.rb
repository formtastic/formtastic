require 'inputs/new_base/timeish'

module Formtastic
  module Inputs
    # @see Formtastic::Inputs::Timeish Timeish module for documetation of date, time and datetime input options.
    class TimeInput 
      include NewBase
      include NewBase::Timeish
      
      # we don't want year / month / day fragments in a time select
      def date_fragments
        []
      end
    end
  end
end