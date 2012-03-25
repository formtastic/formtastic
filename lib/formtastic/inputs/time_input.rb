module Formtastic
  module Inputs
    class TimeInput < TimeSelectInput
      def to_html
        ::ActiveSupport::Deprecation.warn("TimeInput (:as => :time) has been renamed to TimeSelectInput (:as => :time_select) and will be removed or changed in the next version of Formtastic, please update your forms.", caller(2))
        super
      end
    end
  end
end
