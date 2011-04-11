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
    configure :i18n_lookups_by_default, true
    configure :escape_html_entities_in_hints_and_labels, true
    configure :default_commit_button_accesskey
    configure :default_inline_error_class, 'inline-errors'
    configure :default_error_list_class, 'errors'
    configure :default_hint_class, 'inline-hints'

    attr_reader :template
    
    attr_reader :auto_index

    include Formtastic::HtmlAttributes

    include Formtastic::Helpers::InputHelper
    include Formtastic::Helpers::InputsHelper
    include Formtastic::Helpers::ButtonsHelper
    include Formtastic::Helpers::ErrorsHelper
    
    # A thin wrapper around `ActionView::Helpers::FormBuilder#fields_for` helper to set 
    # `:builder => Formtastic::FormBuilder` for nesting forms inside the builder. Can be used in 
    # the same way, but you'll also have access to the helpers in `Formtastic::FormBuilder` 
    # (such as {#input}, etc) inside the block.
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
    def semantic_fields_for(record_or_name_or_array, *args, &block)
      opts = args.extract_options!
      opts[:builder] ||= self.class
      args.push(opts)
      fields_for(record_or_name_or_array, *args, &block)
    end
    
  end

end