module Formtastic

  # Uses the +NamespacedClassFinder+ to look up input class names.
  #
  # See +Formtastic::Helpers::InputHelper#input_class+ for details.
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
