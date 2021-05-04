# frozen_string_literal: true
module Formtastic

  # Uses the {NamespacedClassFinder} to look up action class names.
  #
  # See {Formtastic::Helpers::ActionHelper#namespaced_action_class} for details.
  #
  class ActionClassFinder < NamespacedClassFinder

    # @param builder [FormBuilder]
    def initialize(builder)
      super builder.action_namespaces
    end

    def class_name(as)
      "#{super}Action"
    end
  end
end
