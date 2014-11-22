module Formtastic
  # This class implements class resolution in a namespace chain. It
  # is used both by Formtastic::Helpers::InputHelper and
  # Formtastic::Helpers::ActionHelper to look up action and input classes.
  #
  # @example Implementing own class finder
  #   # You can implement own class finder that for example prefixes the class name or uses custom module.
  #   class MyInputClassFinder < Formtastic::NamespacedClassFinder
  #     def initialize(namespaces)
  #       super [MyNamespace] + namespaces # first lookup in MyNamespace then the defaults
  #     end
  #
  #     private
  #
  #     def class_name(as)
  #       "My#{super}Input" # for example MyStringInput
  #     end
  #   end
  #
  #   # in config/initializers/formtastic.rb
  #   Formtastic::FormBuilder.input_class_finder = MyInputClassFinder
  #

  class NamespacedClassFinder
    attr_reader :namespaces # @private

    # @private
    class NotFoundError < NameError
    end

    def self.use_const_defined?
      defined?(Rails) && ::Rails.application && ::Rails.application.config.eager_load
    end

    # @param namespaces [Array<Module>]
    def initialize(namespaces)
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

    # Converts symbol to class name
    # Overridden in subclasses to create `StringInput` and `ButtonAction`
    # @example
    #   class_name(:string) == "String"

    def class_name(as)
      as.to_s.camelize
    end

    private

    if use_const_defined?
      def finder(class_name) # @private
        find_with_const_defined(class_name)
      end
    else
      def finder(class_name) # @private
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
