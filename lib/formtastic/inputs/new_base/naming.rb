module Formtastic
  module Inputs
    module NewBase
      module Naming

        def as
          self.class.name.split("::").last.underscore.gsub(/_input$/, '')
        end
        
        def sanitized_object_name
          object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
        end

        def sanitized_method_name
          method.to_s.gsub(/[\?\/\-]$/, '')
        end

        def attributized_method_name
          method.to_s.gsub(/_id$/, '').to_sym
        end
        
        def humanized_method_name
          if object && object.class.respond_to?(:human_attribute_name)
            object.class.human_attribute_name(method.to_s)
          else
            method.to_s.send(builder.label_str_method)
          end
        end
      
      end
    end
  end
end