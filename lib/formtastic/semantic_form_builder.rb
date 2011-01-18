module Formtastic
  # Quick hack/shim so that any code expecting the old SemanticFormBuilder class still works.
  # TODO remove from 2.0 with a helpful upgrade path/warning.
  # @private
  class SemanticFormBuilder < Formtastic::FormBuilder
  end
end