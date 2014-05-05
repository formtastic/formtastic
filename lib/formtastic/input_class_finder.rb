module Formtastic
  class InputClassFinder < NamespacedClassFinder
    def initialize(*)
      super
      @namespaces << Formtastic::Inputs
    end

    def class_name(as)
      "#{super}Input"
    end
  end
end
