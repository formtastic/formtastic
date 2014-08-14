module Formtastic

  # Uses the +NamespacedClassFinder+ to look up action class names.
  #
  # See +Formtastic::Helpers::ActionHelper#action_class+ for details.
  #
  class ActionClassFinder < NamespacedClassFinder
    def initialize(builder)
      super builder.action_namespaces
    end

    private

    def class_name(as)
      "#{super}Action"
    end
  end
end
