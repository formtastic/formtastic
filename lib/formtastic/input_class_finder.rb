# frozen_string_literal: true
module Formtastic

  # Uses the {Formtastic::NamespacedClassFinder} to look up input class names.
  #
  # See {Formtastic::FormBuilder#namespaced_input_class} for details.
  #
  class InputClassFinder < NamespacedClassFinder

    # @param builder [FormBuilder]
    def initialize(builder)
      super builder.input_namespaces
    end

    def class_name(as)
      "#{super}Input"
    end
  end
end
