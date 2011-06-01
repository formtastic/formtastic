module Formtastic
  # @private
  module LocalizedString

    protected

    # Internal generic method for looking up localized values within Formtastic
    # using I18n, if no explicit value is set and I18n-lookups are enabled.
    #
    # Enabled/Disable this by setting:
    #
    #   Formtastic::FormBuilder.i18n_lookups_by_default = true/false
    #
    # Lookup priority:
    #
    #   'formtastic.%{type}.%{model}.%{action}.%{attribute}'
    #   'formtastic.%{type}.%{model}.%{attribute}'
    #   'formtastic.%{type}.%{attribute}'
    #
    # Example:
    #
    #   'formtastic.labels.post.edit.title'
    #   'formtastic.labels.post.title'
    #   'formtastic.labels.title'
    #
    # NOTE: Generic, but only used for form input titles/labels/hints/actions (titles = legends, actions = buttons).
    #
    def localized_string(key, value, type, options = {}) #:nodoc:
      key = value if value.is_a?(::Symbol)

      if value.is_a?(::String)
        escape_html_entities(value)
      else
        use_i18n = value.nil? ? i18n_lookups_by_default : (value != false)

        if use_i18n
          model_name, nested_model_name  = normalize_model_name(self.model_name.underscore)

          action_name = template.params[:action].to_s rescue ''
          attribute_name = key.to_s

          defaults = Formtastic::I18n::SCOPES.reject do |i18n_scope|
            nested_model_name.nil? && i18n_scope.match(/nested_model/)
          end.collect do |i18n_scope|
            i18n_path = i18n_scope.dup
            i18n_path.gsub!('%{action}', action_name)
            i18n_path.gsub!('%{model}', model_name)
            i18n_path.gsub!('%{nested_model}', nested_model_name) unless nested_model_name.nil?
            i18n_path.gsub!('%{attribute}', attribute_name)
            i18n_path.gsub!('..', '.')
            i18n_path.to_sym
          end
          defaults << ''

          defaults.uniq!

          default_key = defaults.shift
          i18n_value = Formtastic::I18n.t(default_key,
            options.merge(:default => defaults, :scope => type.to_s.pluralize.to_sym))
          i18n_value = i18n_value.is_a?(::String) ? i18n_value : nil
          if i18n_value.blank? && type == :label
            # This is effectively what Rails label helper does for i18n lookup
            options[:scope] = [:helpers, type]
            options[:default] = defaults
            i18n_value = ::I18n.t(default_key, options)
          end
          (i18n_value.is_a?(::String) && i18n_value.present?) ? escape_html_entities(i18n_value) : nil
        end
      end
    end

    def model_name
      @object.present? ? @object.class.name : @object_name.to_s.classify
    end

    def normalize_model_name(name)
      if !name =~ /\[/ && self.respond_to?(:builder) && builder.respond_to?(:parent_builder) && builder.parent_builder.object_name
        # Rails 3.1 nested builder case
        [builder.parent_builder.object_name.to_s, name]
      elsif name =~ /(.+)\[(.+)\]/
        # Rails 3 (and 3.1?) nested builder case with :post rather than @post
        [$1, $2]
      elsif self.respond_to?(:builder) && builder.respond_to?(:options) && builder.options.key?(:parent_builder)
        # Rails 3.0 nested builder work-around case, where :parent_builder is provided by f.semantic_form_for
        [builder.options[:parent_builder].object_name.to_s, name]
      else
        # Non-nested case
        [name]
      end
    end

    def escape_html_entities(string) #:nodoc:
      if (respond_to?(:builder) && builder.escape_html_entities_in_hints_and_labels) ||
         (self.respond_to?(:escape_html_entities_in_hints_and_labels) && escape_html_entities_in_hints_and_labels)
        string = template.escape_once(string) unless string.respond_to?(:html_safe?) && string.html_safe? == true # Acceppt html_safe flag as indicator to skip escaping
      end
      string
    end

    def i18n_lookups_by_default
      respond_to?(:builder) ? builder.i18n_lookups_by_default : i18n_lookups_by_default
    end

  end
end