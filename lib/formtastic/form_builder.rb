# frozen_string_literal: true
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

    # Check {Formtastic::ActionClassFinder} to see how are inputs resolved.
    configure :action_class_finder, Formtastic::ActionClassFinder
    configure :action_namespaces, [::Object, ::Formtastic::Actions]
    configure :all_fields_required_by_default, true
    configure :collection_label_methods, %w[to_label display_name full_name name title username login value to_s]
    configure :collection_value_methods, %w[id to_s]
    configure :custom_namespace
    configure :default_commit_button_accesskey
    configure :default_error_list_class, 'errors'
    configure :default_hint_class, 'inline-hints'
    configure :default_inline_error_class, 'inline-errors'
    configure :default_text_area_height, 20
    configure :default_text_area_width
    configure :default_text_field_size
    configure :escape_html_entities_in_hints_and_labels, true
    configure :file_metadata_suffixes, ['content_type', 'file_name', 'file_size']
    configure :file_methods, [ :file?, :public_filename, :filename ]
    configure :i18n_cache_lookups, true
    configure :i18n_localizer, Formtastic::Localizer
    configure :i18n_lookups_by_default, true
    configure :include_blank_for_select_by_default, true
    configure :inline_errors, :sentence
    # Check {Formtastic::InputClassFinder} to see how are inputs resolved.
    configure :input_class_finder, Formtastic::InputClassFinder
    configure :input_namespaces, [::Object, ::Formtastic::Inputs]
    configure :label_str_method, :humanize
    configure :optional_string, ''
    configure :perform_browser_validations, false
    configure :priority_countries, ["Australia", "Canada", "United Kingdom", "United States"]
    configure :priority_time_zones, []
    configure :required_string, proc { %{<abbr title="#{Formtastic::I18n.t(:required)}">*</abbr>}.html_safe }
    configure :semantic_errors_link_to_inputs, false
    configure :skipped_columns, [:created_at, :updated_at, :created_on, :updated_on, :lock_version, :version]
    configure :use_required_attribute, false

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

