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
    configure :required_string, proc { Formtastic::Util.html_safe(%{<abbr title="#{Formtastic::I18n.t(:required)}">*</abbr>}) }
    configure :optional_string, ''
    configure :inline_errors, :sentence
    configure :label_str_method, :humanize
    configure :collection_label_methods, %w[to_label display_name full_name name title username login value to_s]
    configure :collection_value_methods, %w[id to_s]
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

    attr_reader :template
    
    attr_reader :auto_index

    include Formtastic::HtmlAttributes

    include Formtastic::Helpers::InputsHelper
    include Formtastic::Helpers::ButtonsHelper
    include Formtastic::Helpers::ErrorsHelper
  end

end