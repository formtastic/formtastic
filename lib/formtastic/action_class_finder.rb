module Formtastic
  class ActionClassFinder < NamespacedClassFinder
    def class_name(as)
      "#{super}Action"
    end
  end
end
