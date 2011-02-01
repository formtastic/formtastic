$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

require 'html_attributes'

require 'helpers/inputs_helper'
require 'helpers/buttons_helper'
require 'helpers/label_helper'
require 'helpers/errors_helper'
require 'helpers/validation_helper'

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
require 'inputs/range_input'
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
    configure :required_string, proc { Formtastic::Util.html_safe(%{<abbr title="#{Formtastic::I18n.t(:required)}">*</abbr>}) }
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
    
    include Formtastic::HtmlAttributes
    
    include Formtastic::Helpers::InputsHelper
    include Formtastic::Helpers::ButtonsHelper
    include Formtastic::Helpers::LabelHelper
    include Formtastic::Helpers::ErrorsHelper
    include Formtastic::Helpers::ValidationHelper

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
    include Formtastic::Inputs::RangeInput
    include Formtastic::Inputs::SearchInput
    include Formtastic::Inputs::SelectInput
    include Formtastic::Inputs::StringInput
    include Formtastic::Inputs::TextInput
    include Formtastic::Inputs::TimeInput
    include Formtastic::Inputs::TimeZoneInput
    include Formtastic::Inputs::UrlInput
    
  end
  
end
