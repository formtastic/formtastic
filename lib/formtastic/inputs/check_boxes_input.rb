# frozen_string_literal: true
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
    #   <%= f.input :categories, :as => :check_boxes, :collection => Category.pluck(:label, :id) %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [Category.find_by_name("Ruby"), Category.find_by_name("Rails")] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => ["Ruby", "Rails"] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", "ruby"], ["Rails", "rails"]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", "1"], ["Rails", "2"]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", 1], ["Rails", 2]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", 1, {'data-attr' => 'attr-value'}]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => 1..5 %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [:ruby, :rails] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => [["Ruby", :ruby], ["Rails", :rails]] %>
    #   <%= f.input :categories, :as => :check_boxes, :collection => Set.new([:ruby, :rails]) %>
    #
    # @example `:hidden_fields` can be used to skip Rails' rendering of a hidden field before every checkbox
    #   <%= f.input :categories, :as => :check_boxes, :hidden_fields => false %>
    #
    # @example `:disabled` can be used to disable any checkboxes with a value found in the given Array
    #   <%= f.input :categories, :as => :check_boxes, :collection => ["a", "b"], :disabled => ["a"] %>
    #
    # @example `:value_as_class` can be used to add a class to the `<li>` wrapped around each choice using the checkbox value for custom styling of each choice
    #   <%= f.input :categories, :as => :check_boxes, :value_as_class => true %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    # @see Formtastic::Inputs::BooleanInput BooleanInput for a single checkbox for boolean (checked = true) inputs
    #
    # @todo Do/can we support the per-item HTML options like RadioInput?
    class CheckBoxesInput
      include Base
      include Base::Collections
      include Base::Choices

      def initialize(*args)
        super
        raise Formtastic::UnsupportedEnumCollection if collection_from_enum?
      end

      def to_html
        input_wrapping do
          choices_wrapping do
            legend_html <<
            hidden_field_for_all <<
            choices_group_wrapping do
              collection.map { |choice|
                choice_wrapping(choice_wrapping_html_options(choice)) do
                  choice_html(choice)
                end
              }.join("\n").html_safe
            end
          end
        end
      end

      def choice_html(choice)
        template.content_tag(
          :label,
          checkbox_input(choice) + choice_label(choice),
          label_html_options.merge(:for => choice_input_dom_id(choice), :class => nil)
        )
      end

      def hidden_field_for_all
        if hidden_fields_for_every?
          +''
        else
          options = {}
          options[:class] = [method.to_s.singularize, 'default'].join('_') if value_as_class?
          options[:id] = [object_name, method, 'none'].join('_')
          template.hidden_field_tag(input_name, '', options)
        end
      end

      def hidden_fields_for_every?
        options[:hidden_fields]
      end

      def check_box_with_hidden_input(choice)
        value = choice_value(choice)
        builder.check_box(
          association_primary_key || method,
          extra_html_options(choice).merge(:id => choice_input_dom_id(choice), :name => input_name, :disabled => disabled?(value), :required => false),
          value,
          unchecked_value
        )
      end

      def check_box_without_hidden_input(choice)
        value = choice_value(choice)
        template.check_box_tag(
          input_name,
          value,
          checked?(value),
          extra_html_options(choice).merge(:id => choice_input_dom_id(choice), :disabled => disabled?(value), :required => false)
        )
      end

      def extra_html_options(choice)
        input_html_options.merge(custom_choice_html_options(choice))
      end

      def checked?(value)
        selected_values.include?(value)
      end

      def disabled?(value)
        disabled_values.include?(value)
      end

      def selected_values
        @selected_values ||= make_selected_values
      end

      def disabled_values
        vals = options[:disabled] || []
        vals = [vals] unless vals.is_a?(Array)
        vals
      end

      def unchecked_value
        options[:unchecked_value] || ''
      end

      def input_name
        if builder.options.key?(:index)
          "#{object_name}[#{builder.options[:index]}][#{association_primary_key || method}][]"
        else
          "#{object_name}[#{association_primary_key || method}][]"
        end
      end

      protected

      def checkbox_input(choice)
        if hidden_fields_for_every?
          check_box_with_hidden_input(choice)
        else
          check_box_without_hidden_input(choice)
        end
      end

      def make_selected_values
        if object.respond_to?(method)
          selected_items = object.send(method)
          # Construct an array from the return value, regardless of the return type
          selected_items = [*selected_items].compact.flatten

          selected = []
          selected_items.map do |selected_item|
            selected_item_id = selected_item.id if selected_item.respond_to? :id
            item = send_or_call_or_object(value_method, selected_item) || selected_item_id
          end.compact
        else
          []
        end
      end
    end
  end
end
