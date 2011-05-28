module Formtastic
  # Quick hack/shim for anything expecting the old SemanticFormHelper module.
  # TODO remove from 2.0 with a helpful upgrade path/warning.
  # @private
  module SemanticFormHelper
    include Formtastic::Helpers::FormHelper
    @@builder = Formtastic::Helpers::FormHelper.builder
    @@default_form_class = Formtastic::Helpers::FormHelper.default_form_class
    mattr_accessor :builder, :default_form_class
  end
end