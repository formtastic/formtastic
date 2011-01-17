$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

require 'helpers/inputs_helper'
require 'helpers/buttons_helper'
require 'helpers/label_helper'
require 'helpers/errors_helper'

require 'inputs/boolean_input'
require 'inputs/check_boxes_input'
require 'inputs/country_input'
require 'inputs/datetime_input'
require 'inputs/date_input'
require 'inputs/email_input'
require 'inputs/file_input'
require 'inputs/hidden_input'
require 'inputs/numeric_input'
require 'inputs/password_input'
require 'inputs/phone_input'
require 'inputs/radio_input'
require 'inputs/search_input'
require 'inputs/select_input'
require 'inputs/string_input'
require 'inputs/text_input'
require 'inputs/time_input'
require 'inputs/time_zone_input'
require 'inputs/url_input'

module Formtastic
  class FormBuilder < ActionView::Helpers::FormBuilder
  
    def self.configure(name, value = nil)
      class_attribute(name)
      self.send(:"#{name}=", value)  
    end
  
    configure :custom_namespace
    configure :default_text_field_size
    configure :default_text_area_height, 20
    configure :default_text_area_width
    configure :all_fields_required_by_default, true
    configure :include_blank_for_select_by_default, true
    configure :required_string, proc { ::Formtastic::Util.html_safe(%{<abbr title="#{::Formtastic::I18n.t(:required)}">*</abbr>}) }
    configure :optional_string, ''
    configure :inline_errors, :sentence
    configure :label_str_method, :humanize
    configure :collection_label_methods, %w[to_label display_name full_name name title username login value to_s]
    configure :collection_value_methods, %w[id to_s]
    configure :inline_order, [ :input, :hints, :errors ]
    configure :custom_inline_order, {}
    configure :file_methods, [ :file?, :public_filename, :filename ]
    configure :file_metadata_suffixes, ['content_type', 'file_name', 'file_size']
    configure :priority_countries, ["Australia", "Canada", "United Kingdom", "United States"]
    configure :i18n_lookups_by_default, false
    configure :escape_html_entities_in_hints_and_labels, true
    configure :default_commit_button_accesskey
    configure :default_inline_error_class, 'inline-errors'
    configure :default_error_list_class, 'errors'
    configure :default_hint_class, 'inline-hints'
  
    attr_accessor :template
    
    include Formtastic::Helpers::InputsHelper
    include Formtastic::Helpers::ButtonsHelper
    include Formtastic::Helpers::LabelHelper
    include Formtastic::Helpers::ErrorsHelper

    include Formtastic::Inputs::BooleanInput
    include Formtastic::Inputs::CheckBoxesInput
    include Formtastic::Inputs::CountryInput
    include Formtastic::Inputs::DateInput
    include Formtastic::Inputs::DatetimeInput
    include Formtastic::Inputs::EmailInput
    include Formtastic::Inputs::FileInput
    include Formtastic::Inputs::HiddenInput
    include Formtastic::Inputs::NumericInput
    include Formtastic::Inputs::PasswordInput
    include Formtastic::Inputs::PhoneInput
    include Formtastic::Inputs::RadioInput
    include Formtastic::Inputs::SearchInput
    include Formtastic::Inputs::SelectInput
    include Formtastic::Inputs::StringInput
    include Formtastic::Inputs::TextInput
    include Formtastic::Inputs::TimeInput
    include Formtastic::Inputs::TimeZoneInput
    include Formtastic::Inputs::UrlInput
    
    protected
      
      # Generate the html id for the li tag.
      # It takes into account options[:index] and @auto_index to generate li
      # elements with appropriate index scope. It also sanitizes the object
      # and method names.
      #
      def generate_html_id(method_name, value='input') #:nodoc:
        index = if options.has_key?(:index)
                  options[:index]
                elsif defined?(@auto_index)
                  @auto_index
                else
                  ""
                end
        sanitized_method_name = method_name.to_s.gsub(/[\?\/\-]$/, '')
  
        [custom_namespace, sanitized_object_name, index, sanitized_method_name, value].reject{|x|x.blank?}.join('_')
      end
  
      def sanitized_object_name #:nodoc:
        @sanitized_object_name ||= @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
      end
  
      def humanized_attribute_name(method) #:nodoc:
        if @object && @object.class.respond_to?(:human_attribute_name)
          humanized_name = @object.class.human_attribute_name(method.to_s)
          if humanized_name == method.to_s.send(:humanize)
            method.to_s.send(label_str_method)
          else
            humanized_name
          end
        else
          method.to_s.send(label_str_method)
        end
      end
  
      # Internal generic method for looking up localized values within Formtastic
      # using I18n, if no explicit value is set and I18n-lookups are enabled.
      #
      # Enabled/Disable this by setting:
      #
      #   Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true/false
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
  
            defaults = ::Formtastic::I18n::SCOPES.reject do |i18n_scope|
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
            i18n_value = ::Formtastic::I18n.t(default_key,
              options.merge(:default => defaults, :scope => type.to_s.pluralize.to_sym))
            if i18n_value.blank? && type == :label
              # This is effectively what Rails label helper does for i18n lookup
              options[:scope] = [:helpers, type]
              options[:default] = defaults
              i18n_value = ::I18n.t(default_key, options)
            end
            i18n_value = escape_html_entities(i18n_value) if i18n_value.is_a?(::String)
            i18n_value.blank? ? nil : i18n_value
          end
        end
      end
  
      def model_name
        @object.present? ? @object.class.name : @object_name.to_s.classify
      end
  
      def normalize_model_name(name)
        if name =~ /(.+)\[(.+)\]/
          [$1, $2]
        else
          [name]
        end
      end
    
  end
  
  # Quick hack/shim so that any code expecting the old SemanticFormBuilder class still works.
  # TODO: migrate everything across
  class SemanticFormBuilder < Formtastic::FormBuilder
  end
  
end