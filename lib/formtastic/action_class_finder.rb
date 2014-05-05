module Formtastic
  class ActionClassFinder < NamespacedClassFinder
    def initialize(*)
      super
      @namespaces << Formtastic::Actions
    end

    def class_name(as)
      "#{super}Action"
    end
  end
end
