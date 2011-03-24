module Formtastic
  module Inputs
    module NewBase
      module Hints

        def hint?
          !hint_text.blank? && !hint_text.kind_of?(Hash)
        end

        def hint_text
          localized_string(method, options[:hint], :hint)
        end
        
        def hint_text_from_options
          options[:hint]
        end

      end
    end
  end
end
