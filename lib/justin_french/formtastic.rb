module JustinFrench
  module Formtastic
    class SemanticFormBuilder < ::Formtastic::SemanticFormBuilder
      def initialize(*args)
        ::ActiveSupport::Deprecation.warn("JustinFrench::Formtastic::SemanticFormBuilder is depreciated. User Formtastic::SemanticFormBuilder instead", caller)
        super
      end
    end
  end
end
