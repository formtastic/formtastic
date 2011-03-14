module Formtastic
  module Inputs
    module NewBase
      module Hints

        def hint?
          !hint.blank? && !hint.kind_of?(Hash)
        end

        def hint
          builder.send(:localized_string, method, options[:hint], :hint)
        end

      end
    end
  end
end
