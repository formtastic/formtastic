module Formtastic

  # Uses the Formtastic::NamespacedClassFinder to look up input class names.
  #
  # See Formtastic::Helpers::InputHelper#namespaced_input_class for details.
  #
  class InputClassFinder < NamespacedClassFinder
    def initialize(builder)
      super builder.input_namespaces
    end

    private

    def class_name(as)
      "#{super}Input"
    end
  end
end
