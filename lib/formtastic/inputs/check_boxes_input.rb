require 'inputs/base'

module Formtastic
  module Inputs

    # A CheckBoxes input is used to render a series of checkboxes. This is an alternative input choice
    # for `has_many` or `has_and_belongs_to_many` associations like a `Post` belonging to many
    # `categories` (by default, a {SelectInput `:select`} input is used, allowing multiple selections).
    #
    # Within the standard `<li>` wrapper, the output is a `<fieldset>` with a `<legend>` to
    # represent the "label" for the input, and an `<ol>` containing `<li>`s for each choice in
    # the association. Each `<li>` choice contains a hidden `<input>` tag for the "unchecked"
    # value (like Rails), and a `<label>` containing the checkbox `<input>` and the label text
    # for each choice.
    #
    # @example Basic example with full form context
    #
    #   <%= semantic_form_for @post do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :categories, :as => :check_boxes %>
    #     <% end %>
    #   <% end %>
    #
    #   <li class='check_boxes'>
    #     <fieldset>
    #       <legend class="label"><label>Categories</label></legend>
    #       <ol>
    #         <li>
    #           <input type="hidden" name="post[category_ids][1]" value="">
    #           <label for="post_category_ids_1"><input id="post_category_ids_1" name="post[category_ids][1]" type="checkbox" value="1" /> Ruby</label>
    #         </li>
    #         <li>
    #           <input type="hidden" name="post[category_ids][2]" value="">
    #           <label for="post_category_ids_2"><input id="post_category_ids_2" name="post[category_ids][2]" type="checkbox" value="2" /> Rails</label>
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </li>
    #
    # @example `:collection` can be used to customize the choices
    #   <%= f.input :categories, :as => :check_boxes, :collection => @categories %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => Category.all %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => Category.some_named_scope %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [Category.find_by_name("Ruby"), Category.find_by_name("Rails")] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => ["Ruby", "Rails"] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", "ruby"], ["Rails", "rails"]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", "1"], ["Rails", "2"]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", 1], ["Rails", 2]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => 1..5 %>
    #
    # @example `:hidden_fields` can be used to skip Rails' rendering of a hidden field before every checkbox
    #   <%= f.input :categories, :as => :check_boxes, :hidden_fields => false %>
    #
    # @example `:disabled` can be used to disable any checkboxes with a value found in the given Array
    #   <%= f.input :categories, :as => :check_boxes, :collection => ["a", "b"], :disabled => ["a"] %>
    #
    # @example `:label_method` can be used to call a different method (or a Proc) on each object in the collection for rendering the label text (it'll try the methods like `to_s` in `collection_label_methods` config by default)
    #   <%= f.input :categories, :as => :check_boxes, :label_method => :name %>
    #   <%= f.input :categories, :as => :check_boxes, :label_method => :name_with_post_count
    #   <%= f.input :categories, :as => :check_boxes, :label_method => Proc.new { |c| "#{c.name} (#{pluralize("post", c.posts.count)})" }
    #
    # @example `:value_method` can be used to call a different method (or a Proc) on each object in the collection for rendering the value for each checkbox (it'll try the methods like `id` in `collection_value_methods` config by default)
    #   <%= f.input :categories, :as => :check_boxes, :value_method => :code %>
    #   <%= f.input :categories, :as => :check_boxes, :value_method => :isbn
    #   <%= f.input :categories, :as => :check_boxes, :value_method => Proc.new { |c| c.name.downcase.underscore }
    #
    # @example `:value_as_class` can be used to add a class to the `<li>` wrapped around each choice using the checkbox value for custom styling of each choice
    #   <%= f.input :categories, :as => :check_boxes, :value_as_class => true %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    # @see Formtastic::Inputs::BooleanInput BooleanInput for a single checkbox for boolean (checked = true) inputs
    module CheckBoxesInput
      include Formtastic::Inputs::Base

      def check_boxes_input(method, options)
        collection = find_collection_for_column(method, options)
        html_options = options.delete(:input_html) || {}

        input_name      = generate_association_input_name(method)
        hidden_fields   = options.delete(:hidden_fields)
        value_as_class  = options.delete(:value_as_class)
        unchecked_value = options.delete(:unchecked_value) || ''
        html_options    = { :name => "#{@object_name}[#{input_name}][]" }.merge(html_options)
        input_ids       = []

        selected_values = find_selected_values_for_column(method, options)
        disabled_option_is_present = options.key?(:disabled)
        disabled_values = [*options[:disabled]] if disabled_option_is_present

        li_options = value_as_class ? { :class => [method.to_s.singularize, 'default'].join('_') } : {}

        list_item_content = collection.map do |c|
          label = c.is_a?(Array) ? c.first : c
          value = c.is_a?(Array) ? c.last : c
          input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
          input_ids << input_id

          html_options[:checked] = selected_values.include?(value)
          html_options[:disabled] = disabled_values.include?(value) if disabled_option_is_present
          html_options[:id] = input_id

          li_content = template.content_tag(:label,
            Formtastic::Util.html_safe("#{create_check_boxes(input_name, html_options, value, unchecked_value, hidden_fields)} #{escape_html_entities(label)}"),
            :for => input_id
          )

          li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
          template.content_tag(:li, Formtastic::Util.html_safe(li_content), li_options)
        end

        fieldset_content = legend_tag(method, options)
        fieldset_content << create_hidden_field_for_check_boxes(input_name, value_as_class) unless hidden_fields
        fieldset_content << template.content_tag(:ol, Formtastic::Util.html_safe(list_item_content.join))
        template.content_tag(:fieldset, fieldset_content)
      end

      protected

      # Used by check_boxes input. The selected values will be set by retrieving the value
      # through the association.
      #
      # If the collection is not a hash or an array of strings, fixnums or symbols,
      # we use value_method to retrieve an array with the values
      def find_selected_values_for_column(method, options)
        if object.respond_to?(method)
          collection = [object.send(method)].compact.flatten
          label, value = detect_label_and_value_method!(collection, options)
          [*collection.map { |o| send_or_call(value, o) }].compact
        else
          []
        end
      end

      # Outputs a custom hidden field for check_boxes
      def create_hidden_field_for_check_boxes(method, value_as_class) #:nodoc:
        options = value_as_class ? { :class => [method.to_s.singularize, 'default'].join('_') } : {}
        input_name = "#{object_name}[#{method.to_s}][]"
        template.hidden_field_tag(input_name, '', options)
      end

      # Outputs a checkbox tag. If called with hidden_fields = true a plain check_box_tag is returned,
      # otherwise the helper uses the output generated by the rails check_box method.
      def create_check_boxes(input_name, html_options = {}, checked_value = "1", unchecked_value = "0", hidden_fields = false) #:nodoc:
        return template.check_box_tag(input_name, checked_value, html_options[:checked], html_options) unless hidden_fields == true
        check_box(input_name, html_options, checked_value, unchecked_value)
      end

      def send_or_call(duck, object)
        if duck.is_a?(Proc)
          duck.call(object)
        else
          object.send(duck)
        end
      end

    end
  end
end