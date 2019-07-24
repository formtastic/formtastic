module Formtastic
  class Reflection
    delegate :options, :klass, to: :@_reflection
    attr_reader :_reflection

     def initialize(reflection)
      @_reflection = reflection
    end

     def macro
      respond_to_macro? ? _reflection.macro : macro_from_class
    end

     def primary_key
      case macro
      when :has_and_belongs_to_many, :has_many, :references_and_referenced_in_many, :references_many
        :"#{_reflection.name.to_s.singularize}_ids"
      else
        return _reflection.foreign_key.to_sym if _reflection.respond_to?(:foreign_key)
        return _reflection.options[:foreign_key].to_sym unless _reflection.options[:foreign_key].blank?
        :"#{_reflection.name}_id"
      end
    end

     def respond_to_macro?
      _reflection.respond_to(:macro)
    end

     private

     def macro_from_class
      _reflection.class.name.demodulize.underscore.to_sym
    end
  end
end
