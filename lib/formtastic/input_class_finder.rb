module Formtastic
  class InputClassFinder < NamespacedClassFinder
    def class_name(as)
      "#{super}Input"
    end
  end
end
