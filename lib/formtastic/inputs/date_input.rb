module Formtastic
  module Inputs
    class DateInput < DateSelectInput
      def to_html
        ::ActiveSupport::Deprecation.warn("DateInput (:as => :date) has been renamed to DateSelectInput (:as => :date_select) and will be removed or changed in the next version of Formtastic, please update your forms.", caller(2))
        super
      end
    end
  end
end
