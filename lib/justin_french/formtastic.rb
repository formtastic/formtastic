module JustinFrench #:nodoc:
  module Formtastic #:nodoc:
    class SemanticFormBuilder < ::Formtastic::SemanticFormBuilder #:nodoc:
      def initialize(*args)
        ::ActiveSupport::Deprecation.warn("JustinFrench::Formtastic::SemanticFormBuilder is deprecated. User Formtastic::SemanticFormBuilder instead", caller)
        super
      end
    end
  end
end
