module Formtastic
  class Reflection
    delegate :klass, to: :@_reflection

    def initialize(reflection)
      @_reflection = reflection
    end

    def options
      return {} unless @_reflection.respond_to?(:options)

      @_reflection.options
    end

    def macro
      if @_reflection.respond_to?(:macro)
        @_reflection.macro
      else
        @_reflection.class.name.demodulize.underscore.to_sym
      end
    end

    def primary_key(method)
      case macro
      when :has_and_belongs_to_many, :has_many, :references_and_referenced_in_many, :references_many
        :"#{method.to_s.singularize}_ids"
      else
        return @_reflection.foreign_key.to_sym if @_reflection.respond_to?(:foreign_key)
        return @_reflection.options[:foreign_key].to_sym unless @_reflection.options[:foreign_key].blank?
        :"#{method}_id"
      end
    end
  end
end
