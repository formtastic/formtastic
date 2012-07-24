module Formtastic
  module LocalizedString

    def model_name
      @object.present? ? @object.class.name : @object_name.to_s.classify
    end

    def model_names
      unless @model_names
        model_class   = @object.class
        base_class    = model_class.respond_to?(:base_class) ? model_class.base_class : Object
        classes       = (model_class.ancestors - model_class.included_modules)
        classes       = classes[0...classes.index(base_class)]
        @model_names  = classes.map { |c| c.name.underscore }
      end

      @model_names
    end

    protected

    def localized_string(key, value, type, options = {}) #:nodoc:
      current_builder = respond_to?(:builder) ? builder : self
      localizer = Formtastic::FormBuilder.i18n_localizer.new(current_builder)
      localizer.localize(key, value, type, options)
    end

  end
end
