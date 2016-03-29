module Formtastic
  class FormBuilder < ActionView::Helpers::FormBuilder

    # Defines a new configurable option
    # @param [Symbol] name the configuration name
    # @param [Object] default the configuration default value
    # @private
    #
    # @!macro [new] configure
    #   @!scope class
    #   @!attribute [rw] $1
    #   @api public
    def self.configure(name, default = nil)
      class_attribute(name)
      self.send(:"#{name}=", default)
    end

    configure :custom_namespace
    configure :default_text_field_size
    configure :default_text_area_height, 20
    configure :default_text_area_width
    configure :all_fields_required_by_default, true
    configure :include_blank_for_select_by_default, true
    configure :required_string, proc { %{<abbr title="#{Formtastic::I18n.t(:required)}">*</abbr>}.html_safe }
    configure :optional_string, ''
    configure :inline_errors, :sentence
    configure :label_str_method, :humanize
    configure :collection_label_methods, %w[to_label display_name full_name name title username login value to_s]
    configure :collection_value_methods, %w[id to_s]
    configure :file_methods, [ :file?, :public_filename, :filename ]
    configure :file_metadata_suffixes, ['content_type', 'file_name', 'file_size']
    configure :priority_countries, ["Australia", "Canada", "United Kingdom", "United States"]
    configure :i18n_lookups_by_default, true
    configure :i18n_cache_lookups, true
    configure :i18n_localizer, Formtastic::Localizer
    configure :escape_html_entities_in_hints_and_labels, true
    configure :default_commit_button_accesskey
    configure :default_inline_error_class, 'inline-errors'
    configure :default_error_list_class, 'errors'
    configure :default_hint_class, 'inline-hints'
    configure :use_required_attribute, false
    configure :perform_browser_validations, false
    # Check {Formtastic::InputClassFinder} to see how are inputs resolved.
    configure :input_namespaces, [::Object, ::Formtastic::Inputs]
    configure :input_class_finder, Formtastic::InputClassFinder
    # Check {Formtastic::ActionClassFinder} to see how are inputs resolved.
    configure :action_namespaces, [::Object, ::Formtastic::Actions]
    configure :action_class_finder, Formtastic::ActionClassFinder

    class InputMapping

      class Input
        attr_reader :name

        def initialize(name)
          @name = name
          @matchers = Hash.new { |h,k| h[k] = [] }
        end

        def match_column(name)
          @matchers[:column] << name
        end

        def match_type(type)
          @matchers[:type] << type
        end

        def match_form(matcher = nil, &block)
          @matchers[:form] << (matcher || block)
        end

        def matches_type?(type)
          match?(:type, type)
        end

        def matches_column?(name)
          match?(:column, name)
        end

        def matches_form?(*args)
          match?(:form, args)
        end

        protected

        def match?(name, match)
          matchers = @matchers[name]
          matchers if matchers.none? || matchers.any? { |matcher| matcher === match }
        end
      end

      def initialize(mappings = [])
        @mappings = mappings
      end

      def add_input(name)
        @mappings << input = Input.new(name)
        input
      end

      def to_a
        @mappings.to_a
      end

      def input_name
        input = @mappings.first
        input && input.name
      end

      def select_type(column)
        type = column && column.type

        InputMapping.new @mappings.select { |m| m.matches_type?(type) }
      end

      def select_form(form, method, options)
        InputMapping.new @mappings.select { |m| m.matches_form?(form, method, options) }
      end

      def select_method(name)
        return self unless name

        InputMapping.new @mappings.select { |m| m.matches_column?(name) }
      end

      def find_form(form, method, options)
        InputMapping.new @mappings.select { |m| (match = m.matches_form?(form, method, options)) && match.any? }
      end
    end

    configure :input_mapping, input_mapping = InputMapping.new

    select = input_mapping.add_input(:select)
    select.match_form { |form, method| form.object && form.reflection_for(method) }

    file = input_mapping.add_input(:file)
    file.match_form { |form, method, options| form.object && form.is_file?(method, options) }

    password = input_mapping.add_input(:password)
    password.match_column(/password/)
    password.match_type(:string)
    password.match_type(nil)

    phone = input_mapping.add_input(:phone)
    phone.match_column(/phone|fax/)
    phone.match_type(:string)

    search = input_mapping.add_input(:search)
    search.match_column(/search/)
    search.match_type(:string)

    color = input_mapping.add_input(:color)
    color.match_column(/color/)
    color.match_type(:string)

    country = input_mapping.add_input(:country)
    country.match_column(/country/)
    country.match_type(:string)

    email = input_mapping.add_input(:email)
    email.match_column(/email/)
    email.match_type(:string)

    url = input_mapping.add_input(:url)
    url.match_column(/^url$|^website$|_url$/)
    url.match_type(:string)

    time_select = input_mapping.add_input(:time_select)
    time_select.match_type(:time)

    date_select = input_mapping.add_input(:date_select)
    date_select.match_type(:date)

    datetime_select = input_mapping.add_input(:datetime_select)
    datetime_select.match_type(:datetime)
    datetime_select.match_type(:timestamp)

    select = input_mapping.add_input(:select)
    select.match_type(:integer)
    select.match_form { |form, method| form.reflection_for(method) }
    select.match_form { |form, method| form.enum_for(method) }

    text = input_mapping.add_input(:text)
    text.match_type(:hstore)
    text.match_type(:text)

    boolean = input_mapping.add_input(:boolean)
    boolean.match_type(:boolean)

    number = input_mapping.add_input(:number)
    number.match_type(:integer)
    number.match_type(:float)
    number.match_type(:decimal)

    string = input_mapping.add_input(:string)
    string.match_type(:string)
    string.match_type(nil)

    configure :skipped_columns, [:created_at, :updated_at, :created_on, :updated_on, :lock_version, :version]
    configure :priority_time_zones, []

    attr_reader :template

    attr_reader :auto_index

    include Formtastic::HtmlAttributes

    include Formtastic::Helpers::InputHelper
    include Formtastic::Helpers::InputsHelper
    include Formtastic::Helpers::ActionHelper
    include Formtastic::Helpers::ActionsHelper
    include Formtastic::Helpers::ErrorsHelper

    # This is a wrapper around Rails' `ActionView::Helpers::FormBuilder#fields_for`, originally
    # provided to ensure that the `:builder` from `semantic_form_for` was passed down into
    # the nested `fields_for`. Our supported versions of Rails no longer require us to do this,
    # so this method is provided purely for backwards compatibility and DSL consistency.
    #
    # When constructing a `fields_for` form fragment *outside* of `semantic_form_for`, please use
    # `Formtastic::Helpers::FormHelper#semantic_fields_for`.
    #
    # @see http://api.rubyonrails.org/classes/ActionView/Helpers/FormBuilder.html#method-i-fields_for ActionView::Helpers::FormBuilder#fields_for
    # @see http://api.rubyonrails.org/classes/ActionView/Helpers/FormHelper.html#method-i-fields_for ActionView::Helpers::FormHelper#fields_for
    # @see Formtastic::Helpers::FormHelper#semantic_fields_for
    #
    # @example
    #   <% semantic_form_for @post do |post| %>
    #     <% post.semantic_fields_for :author do |author| %>
    #       <% author.inputs :name %>
    #     <% end %>
    #   <% end %>
    #
    #   <form ...>
    #     <fieldset class="inputs">
    #       <ol>
    #         <li class="string"><input type='text' name='post[author][name]' id='post_author_name' /></li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @todo is there a way to test the params structure of the Rails helper we wrap to ensure forward compatibility?
    def semantic_fields_for(record_or_name_or_array, *args, &block)
      fields_for(record_or_name_or_array, *args, &block)
    end

    def initialize(object_name, object, template, options)
      super

      if respond_to?('multipart=') && options.is_a?(Hash) && options[:html]
        self.multipart = options[:html][:multipart]
      end
    end

  end

end

