$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'helpers')))
$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), '..', 'inputs')))

require 'inputs_helper'
require 'buttons_helper'
require 'label_helper'
require 'errors_helper'

require 'boolean_input'
require 'check_boxes_input'
require 'country_input'
require 'datetime_input'
require 'date_input'
require 'email_input'
require 'file_input'
require 'hidden_input'
require 'numeric_input'
require 'password_input'
require 'phone_input'
require 'radio_input'
require 'search_input'
require 'select_input'
require 'string_input'
require 'text_input'
require 'time_input'
require 'time_zone_input'
require 'url_input'

module Formtastic
  module Builder
    class Base < ActionView::Helpers::FormBuilder
    
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
    
      RESERVED_COLUMNS = [:created_at, :updated_at, :created_on, :updated_on, :lock_version, :version]
    
      INLINE_ERROR_TYPES = [:sentence, :list, :first]
    
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
      
        # Prepare options to be sent to label
        #
        def options_for_label(options) #:nodoc:
          options.slice(:label, :required).merge!(options.fetch(:label_html, {}))
        end
    
        # Remove any Formtastic-specific options before passing the down options.
        #
        def strip_formtastic_options(options) #:nodoc:
          options.except(:value_method, :label_method, :collection, :required, :label,
                         :as, :hint, :input_html, :label_html, :value_as_class, :find_options, :class)
        end
    
        # Generates an input for the given method using the type supplied with :as.
        def inline_input_for(method, options)
          send(:"#{options.delete(:as)}_input", method, options)
        end
    
        # Generates hints for the given method using the text supplied in :hint.
        #
        def inline_hints_for(method, options) #:nodoc:
          options[:hint] = localized_string(method, options[:hint], :hint)
          return if options[:hint].blank? or options[:hint].kind_of? Hash
          hint_class = options[:hint_class] || default_hint_class
          template.content_tag(:p, Formtastic::Util.html_safe(options[:hint]), :class => hint_class)
        end
    
        # Creates an error sentence by calling to_sentence on the errors array.
        #
        def error_sentence(errors, options = {}) #:nodoc:
          error_class = options[:error_class] || default_inline_error_class
          template.content_tag(:p, Formtastic::Util.html_safe(errors.to_sentence.untaint), :class => error_class)
        end
    
        # Creates an error li list.
        #
        def error_list(errors, options = {}) #:nodoc:
          error_class = options[:error_class] || default_error_list_class
          list_elements = []
          errors.each do |error|
            list_elements <<  template.content_tag(:li, Formtastic::Util.html_safe(error.untaint))
          end
          template.content_tag(:ul, Formtastic::Util.html_safe(list_elements.join("\n")), :class => error_class)
        end
    
        # Creates an error sentence containing only the first error
        #
        def error_first(errors, options = {}) #:nodoc:
          error_class = options[:error_class] || default_inline_error_class
          template.content_tag(:p, Formtastic::Util.html_safe(errors.first.untaint), :class => error_class)
        end
        
        # Generates a fieldset and wraps the content in an ordered list. When working
        # with nested attributes, it allows %i as interpolation option in :name. So you can do:
        #
        #   f.inputs :name => 'Task #%i', :for => :tasks
        #
        # or the shorter equivalent:
        #
        #   f.inputs 'Task #%i', :for => :tasks
        #
        # And it will generate a fieldset for each task with legend 'Task #1', 'Task #2',
        # 'Task #3' and so on.
        #
        # Note: Special case for the inline inputs (non-block):
        #   f.inputs "My little legend", :title, :body, :author   # Explicit legend string => "My little legend"
        #   f.inputs :my_little_legend, :title, :body, :author    # Localized (118n) legend with I18n key => I18n.t(:my_little_legend, ...)
        #   f.inputs :title, :body, :author                       # First argument is a column => (no legend)
        #
        def field_set_and_list_wrapping(*args, &block) #:nodoc:
          contents = args.last.is_a?(::Hash) ? '' : args.pop.flatten
          html_options = args.extract_options!
    
          legend  = html_options.dup.delete(:name).to_s
          legend %= parent_child_index(html_options[:parent]) if html_options[:parent]
          legend  = template.content_tag(:legend, template.content_tag(:span, Formtastic::Util.html_safe(legend))) unless legend.blank?
    
          if block_given?
            contents = if template.respond_to?(:is_haml?) && template.is_haml?
              template.capture_haml(&block)
            else
              template.capture(&block)
            end
          end
    
          # Ruby 1.9: String#to_s behavior changed, need to make an explicit join.
          contents = contents.join if contents.respond_to?(:join)
          fieldset = template.content_tag(:fieldset,
            Formtastic::Util.html_safe(legend) << template.content_tag(:ol, Formtastic::Util.html_safe(contents)),
            html_options.except(:builder, :parent)
          )
    
          fieldset
        end
    
        def field_set_title_from_args(*args) #:nodoc:
          options = args.extract_options!
          options[:name] ||= options.delete(:title)
          title = options[:name]
    
          if title.blank?
            valid_name_classes = [::String, ::Symbol]
            valid_name_classes.delete(::Symbol) if !block_given? && (args.first.is_a?(::Symbol) && content_columns.include?(args.first))
            title = args.shift if valid_name_classes.any? { |valid_name_class| args.first.is_a?(valid_name_class) }
          end
          title = localized_string(title, title, :title) if title.is_a?(::Symbol)
          title
        end
    
        # Also generates a fieldset and an ordered list but with label based in
        # method. This methods is currently used by radio and datetime inputs.
        #
        def field_set_and_list_wrapping_for_method(method, options, contents) #:nodoc:
          contents = contents.join if contents.respond_to?(:join)
    
          template.content_tag(:fieldset,
              template.content_tag(:legend,
                  label(method, options_for_label(options).merge(:for => options.delete(:label_for))), :class => 'label'
                ) <<
              template.content_tag(:ol, Formtastic::Util.html_safe(contents))
            )
        end
    
        # Generates the legend for radiobuttons and checkboxes
        def legend_tag(method, options = {})
          if options[:label] == false
            Formtastic::Util.html_safe("")
          else
            text = localized_string(method, options[:label], :label) || humanized_attribute_name(method)
            text += required_or_optional_string(options.delete(:required))
            text = Formtastic::Util.html_safe(text)
            template.content_tag :legend, template.label_tag(nil, text, :for => nil), :class => :label
          end
        end
    
        def is_file?(method, options = {})
          @files ||= {}
          @files[method] ||= (options[:as].present? && options[:as] == :file) || begin
            file = @object.send(method) if @object && @object.respond_to?(method)
            file && file_methods.any?{|m| file.respond_to?(m)}
          end
        end
    
        # Used by select and radio inputs. The collection can be retrieved by
        # three ways:
        #
        # * Explicitly provided through :collection
        # * Retrivied through an association
        # * Or a boolean column, which will generate a localized { "Yes" => true, "No" => false } hash.
        #
        # If the collection is not a hash or an array of strings, fixnums or arrays,
        # we use label_method and value_method to retreive an array with the
        # appropriate label and value.
        #
        def find_collection_for_column(column, options) #:nodoc:
          collection = find_raw_collection_for_column(column, options)
    
          # Return if we have a plain string
          return collection if collection.instance_of?(String) || collection.instance_of?(::Formtastic::Util.rails_safe_buffer_class)
    
          # Return if we have an Array of strings, fixnums or arrays
          return collection if (collection.instance_of?(Array) || collection.instance_of?(Range)) &&
                               [Array, Fixnum, String, Symbol].include?(collection.first.class) &&
                               !(options.include?(:label_method) || options.include?(:value_method))
    
          label, value = detect_label_and_value_method!(collection, options)
          collection.map { |o| [send_or_call(label, o), send_or_call(value, o)] }
        end
    
        # Detects the label and value methods from a collection using methods set in
        # collection_label_methods and collection_value_methods. For some ruby core
        # classes sensible defaults have been defined. It will use and delete the options
        # :label_method and :value_methods when present.
        #
        def detect_label_and_value_method!(collection, options = {})
          sample = collection.first || collection.last
    
          case sample
          when Array
            label, value = :first, :last
          when Integer
            label, value = :to_s, :to_i
          when String, NilClass
            label, value = :to_s, :to_s
          end
    
          # Order of preference: user supplied method, class defaults, auto-detect
          label = options[:label_method] || label || collection_label_methods.find { |m| sample.respond_to?(m) }
          value = options[:value_method] || value || collection_value_methods.find { |m| sample.respond_to?(m) }
    
          [label, value]
        end
    
        # Return the label collection method when none is supplied using the
        # values set in collection_label_methods.
        #
        def detect_label_method(collection) #:nodoc:
          detect_label_and_value_method!(collection).first
        end
    
        # Detects the method to call for fetching group members from the groups when grouping select options
        #
        def detect_group_association(method, group_by)
          object_to_method_reflection = reflection_for(method)
          method_class = object_to_method_reflection.klass
    
          method_to_group_association = method_class.reflect_on_association(group_by)
          group_class = method_to_group_association.klass
    
          # This will return in the normal case
          return method.to_s.pluralize.to_sym if group_class.reflect_on_association(method.to_s.pluralize)
    
          # This is for belongs_to associations named differently than their class
          # form.input :parent, :group_by => :customer
          # eg.
          # class Project
          #   belongs_to :parent, :class_name => 'Project', :foreign_key => 'parent_id'
          #   belongs_to :customer
          # end
          # class Customer
          #   has_many :projects
          # end
          group_method = method_class.to_s.underscore.pluralize.to_sym
          return group_method if group_class.reflect_on_association(group_method) # :projects
    
          # This is for has_many associations named differently than their class
          # eg.
          # class Project
          #   belongs_to :parent, :class_name => 'Project', :foreign_key => 'parent_id'
          #   belongs_to :customer
          # end
          # class Customer
          #   has_many :tasks, :class_name => 'Project', :foreign_key => 'customer_id'
          # end
          possible_associations =  group_class.reflect_on_all_associations(:has_many).find_all{|assoc| assoc.klass == object_class}
          return possible_associations.first.name.to_sym if possible_associations.count == 1
    
          raise "Cannot infer group association for #{method} grouped by #{group_by}, there were #{possible_associations.empty? ? 'no' : possible_associations.size} possible associations. Please specify using :group_association"
    
        end
    
        # Used by association inputs (select, radio) to generate the name that should
        # be used for the input
        #
        #   belongs_to :author; f.input :author; will generate 'author_id'
        #   belongs_to :entity, :foreign_key = :owner_id; f.input :author; will generate 'owner_id'
        #   has_many :authors; f.input :authors; will generate 'author_ids'
        #   has_and_belongs_to_many will act like has_many
        #
        def generate_association_input_name(method) #:nodoc:
          if reflection = reflection_for(method)
            if [:has_and_belongs_to_many, :has_many].include?(reflection.macro)
              "#{method.to_s.singularize}_ids"
            else
              reflection.options[:foreign_key] || "#{method}_id"
            end
          else
            method
          end.to_sym
        end
    
        # If an association method is passed in (f.input :author) try to find the
        # reflection object.
        #
        def reflection_for(method) #:nodoc:
          @object.class.reflect_on_association(method) if @object.class.respond_to?(:reflect_on_association)
        end
    
        # Get a column object for a specified attribute method - if possible.
        #
        def column_for(method) #:nodoc:
          @object.column_for_attribute(method) if @object.respond_to?(:column_for_attribute)
        end
    
        # Returns the active validations for the given method or an empty Array if no validations are
        # found for the method.
        #
        # By default, the if/unless options of the validations are evaluated and only the validations
        # that should be run for the current object state are returned. Pass :all to the last
        # parameter to return :all validations regardless of if/unless options.
        #
        # Requires the ValidationReflection plugin to be present or an ActiveModel. Returns an epmty
        # Array if neither is the case.
        #
        def validations_for(method, mode = :active)
          # ActiveModel?
          validations = if @object && @object.class.respond_to?(:validators_on)
            @object.class.validators_on(method)
          else
            # ValidationReflection plugin?
            if @object && @object.class.respond_to?(:reflect_on_validations_for)
              @object.class.reflect_on_validations_for(method)
            else
              []
            end
          end
    
          validations = validations.select do |validation|
            (validation.options.present? ? options_require_validation?(validation.options) : true)
          end unless mode == :all
    
          return validations
        end
    
        # Generates default_string_options by retrieving column information from
        # the database.
        #
        def default_string_options(method, type) #:nodoc:
          def get_maxlength_for(method)
            validation = validations_for(method).find do |validation|
              (validation.respond_to?(:macro) && validation.macro == :validates_length_of) || # Rails 2 + 3 style validation
              (validation.respond_to?(:kind) && validation.kind == :length) # Rails 3 style validator
            end
    
            if validation
              validation.options[:maximum] || (validation.options[:within].present? ? validation.options[:within].max : nil)
            else
              nil
            end
          end
    
          validation_max_limit = get_maxlength_for(method)
          column = column_for(method)
    
          if type == :text
            { :rows => default_text_area_height, 
              :cols => default_text_area_width }
          elsif type == :numeric || column.nil? || !column.respond_to?(:limit) || column.limit.nil?
            { :maxlength => validation_max_limit,
              :size => default_text_field_size }
          else
            { :maxlength => validation_max_limit || column.limit,
              :size => default_text_field_size }
          end
        end
    
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
    
        # Gets the nested_child_index value from the parent builder. It returns a hash with each
        # association that the parent builds.
        def parent_child_index(parent) #:nodoc:
          duck = parent[:builder].instance_variable_get('@nested_child_index')
    
          child = parent[:for]
          child = child.first if child.respond_to?(:first)
          duck[child].to_i + 1
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
    
        def send_or_call(duck, object)
          if duck.is_a?(Proc)
            duck.call(object)
          else
            object.send(duck)
          end
        end
    
        def set_include_blank(options)
          unless options.key?(:include_blank) || options.key?(:prompt)
            options[:include_blank] = include_blank_for_select_by_default
          end
          options
        end
    
        def escape_html_entities(string) #:nodoc:
          if escape_html_entities_in_hints_and_labels
            # Acceppt html_safe flag as indicator to skip escaping
            string = template.escape_once(string) unless string.respond_to?(:html_safe?) && string.html_safe? == true
          end
          string
        end
      
    end
  end
  
  # Quick hack/shim so that any code expecting the old SemanticFormBuilder class still works.
  # TODO: migrate everything across
  class SemanticFormBuilder < Formtastic::Builder::Base
  end
  
end