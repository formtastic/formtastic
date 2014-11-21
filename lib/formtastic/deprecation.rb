require 'active_support/deprecation'

module Formtastic
  if ActiveSupport::Deprecation.respond_to?(:new)
    Deprecation = ActiveSupport::Deprecation
  else
    require 'forwardable'

    # @private
    # @todo remove this branch and file when support for rails 3.2 is dropped
    class Deprecation
      mattr_accessor :deprecation
      self.deprecation = ActiveSupport::Deprecation.dup

      extend Forwardable
      methods = deprecation.methods - deprecation.class.methods
      def_delegators :deprecation, *methods

      def initialize(version, _library)
        deprecation.silenced = false
        deprecation.deprecation_horizon = version
      end

      def deprecation_warning(deprecated_method_name, message = nil, caller_backtrace = nil)
        caller_backtrace ||= caller(2)

        deprecated_method_warning(deprecated_method_name, message).tap do |msg|
          warn(msg, caller_backtrace)
        end
      end

      def deprecated_method_warning(method_name, message = nil)
        warning = "#{method_name} is deprecated and will be removed from Formtastic #{deprecation_horizon}"
        case message
          when Symbol then "#{warning} (use #{message} instead)"
          when String then "#{warning} (#{message})"
          else warning
        end
      end
    end
  end
end
