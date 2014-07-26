module Formtastic

  # Uses the +NamespacedClassFinder+ to look up input class names.
  #
  # See +Formtastic::Helpers::InputHelper#input_class+ for details.
  #
  class InputClassFinder < NamespacedClassFinder
    def initialize(builder)
      super configured_namespaces(builder, builder.input_namespaces) + [ Formtastic::Inputs ]
    end

    private

    def class_name(as)
      "#{super}Input"
    end
  end
end
