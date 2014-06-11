module Formtastic
  class InputClassFinder < NamespacedClassFinder
    def initialize(builder)
      super configured_namespaces(builder, builder.input_namespaces) + [ Formtastic::Inputs ]
    end

    def class_name(as)
      "#{super}Input"
    end
  end
end
