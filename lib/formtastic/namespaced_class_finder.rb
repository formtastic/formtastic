module Formtastic
  # This class implements class resolution in a namespace chain. It
  # is used both by InputHelper and ActionHelper to look up custom
  # action and input classes.
  #
  # See
  #   +Formtastic::Helpers::InputHelper+
  #   +Formtastic::Helpers::ActionHelper+
  # for details.
  #
  class NamespacedClassFinder
    DEFAULT_NAMESPACE = ::Object

    attr_reader :namespaces #:nodoc:

    # @private
    class NotFoundError < NameError
    end

    def initialize(namespaces) #:nodoc:
      @namespaces = namespaces.flatten
      @cache = {}
    end

    # Looks up the given reference in the configured namespaces.
    #
    # Two finder methods are provided, one for development tries to
    # reference the constant directly, triggering Rails' autoloading
    # const_missing machinery; the second one instead for production
    # checks with .const_defined before referencing the constant.
    #
    def find(as)
      @cache[as] ||= resolve(as)
    end

    def resolve(as)
      class_name = class_name(as)

      finder(class_name) or raise NotFoundError, "class #{class_name}"
    end

    private

    def class_name(as)
      as.to_s.camelize
    end

    if ::Rails.application.config.cache_classes
      def finder(class_name) # :nodoc:
        find_with_const_defined(class_name)
      end
    else
      def finder(class_name) # :nodoc:
        find_by_trying(class_name)
      end
    end

    # Looks up the given class name in the configured namespaces in order,
    # returning the first one that has the class name constant defined.
    def find_with_const_defined(class_name)
      @namespaces.find do |namespace|
        if namespace.const_defined?(class_name)
          break namespace.const_get(class_name)
        end
      end
    end

    # Use auto-loading in development environment
    def find_by_trying(class_name)
      @namespaces.find do |namespace|
        begin
          break namespace.const_get(class_name)
        rescue NameError
        end
      end
    end
  end
end
