module Formtastic
  class ClassFinder


    # @private
    class NotFoundError < NameError
    end

    # possible TODO: this could be initialized together with form builder
    # and cached as instance (with suffix and namespace)
    # then it could have public method #find(as)
    # which would cache the results instead of form builder

    def self.find_class(as, suffix, namespaces)
      new(as, suffix, namespaces).constantize
    end

    def constantize
      ::Rails.application.config.cache_classes ?
        find_with_const_defined! :
        find_by_trying!
    end

    protected

    def initialize(as, suffix, namespaces)
      @as = as
      @suffix = suffix
      @namespaces = namespaces
    end

    def class_name
      @class_name ||= "#{@as.to_s.camelize}#{@suffix}"
    end

    def find_with_const_defined!
      find_with_const_defined or raise ClassFinder::NotFoundError, "class #{class_name}" # in #{@namespaces.to_sentence}
    end

    # prevent exceptions in production environment for better performance
    def find_with_const_defined
      @namespaces.find do |namespace|
        if namespace.const_defined?(class_name)
          break namespace.const_get(class_name)
        end
      end
    end

    def find_by_trying!
      find_by_trying or raise ClassFinder::NotFoundError, "class for #{@as}" # in #{@namespaces.to_sentence}
    end

    # use auto-loading in development environment
    def find_by_trying
      @namespaces.find do |namespace|
        begin
          break namespace.const_get(class_name)
        rescue NameError
        end
      end
    end
  end
end
