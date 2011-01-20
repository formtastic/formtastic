module Formtastic
  # Quick hack/shim so that any code expecting the old SemanticFormBuilder class still works.
  # TODO remove from 2.0 with a helpful upgrade path/warning.
  # @private
  class SemanticFormBuilder < Formtastic::FormBuilder
    def initialize(*args)
      ActiveSupport::Deprecation.warn('Formtastic::SemanticFormBuilder has been deprecated in favor of Formtastic::FormBuilder.', caller)
      super
    end
  end
end