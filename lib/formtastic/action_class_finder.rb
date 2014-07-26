module Formtastic

  # Uses the +NamespacedClassFinder+ to look up action class names.
  #
  # See +Formtastic::Helpers::ActionHelper#action_class+ for details.
  #
  class ActionClassFinder < NamespacedClassFinder
    def initialize(builder)
      super configured_namespaces(builder, builder.action_namespaces) + [ Formtastic::Actions ]
    end

    private

    def class_name(as)
      "#{super}Action"
    end
  end
end
