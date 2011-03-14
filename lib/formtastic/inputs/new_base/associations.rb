module Formtastic
  module Inputs
    module NewBase
      module Associations

        # :belongs_to, etc
        def association
          @association ||= reflection.macro if reflection
        end
        
        def reflection
          @reflection ||= object.class.reflect_on_association(method) if object.class.respond_to?(:reflect_on_association)
        end
        
        def belongs_to?
          association == :belongs_to
        end
      
      end
    end
  end
end
