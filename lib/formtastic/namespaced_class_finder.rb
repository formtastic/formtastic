module Formtastic
  class NamespacedClassFinder
    DEFAULT_NAMESPACE = ::Object

    attr_reader :namespaces

    # @private
    class NotFoundError < NameError
    end

    def initialize(namespaces)
      @namespaces = [ DEFAULT_NAMESPACE, *namespaces ]
      @cache = {}
    end

    def [](as)
      @cache[as] ||= find(as)
    end

    def find(as)
      class_name = class_name(as)

      finder(class_name) or raise NotFoundError, "class #{class_name}"
    end

    def class_name(as)
      as.to_s.camelize
    end

    protected

    def configured_namespaces(builder, config)
      Array.wrap(config.respond_to?(:call) ? builder.class.instance_eval(&config) : config)
    end

    private

    if ::Rails.application.config.cache_classes
      def finder(class_name)
        find_with_const_defined(class_name)
      end
    else
      def finder(class_name)
        find_by_trying(class_name)
      end
    end

    # prevent exceptions in production environment for better performance
    def find_with_const_defined(class_name)
      @namespaces.find do |namespace|
        if namespace.const_defined?(class_name)
          break namespace.const_get(class_name)
        end
      end
    end

    # use auto-loading in development environment
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
