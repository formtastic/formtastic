require 'inputs/new_base'
require 'inputs/new_base/collections'

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
    class CheckBoxesInput
      include NewBase
      include NewBase::Collections
      
      def to_html
        input_wrapping do
          template.content_tag(:fieldset, 
            legend_html <<
            hidden_field_for_all <<
            template.content_tag(:ol,
              collection.map { |choice|
                
                check_box_label = choice.is_a?(Array) ? choice.first : choice
                check_box_value = choice.is_a?(Array) ? choice.last : choice
                
                html_safe_value = check_box_value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase
                check_box_input_id = "#{sanitized_object_name}_#{association_primary_key || method}_#{html_safe_value}"
                check_box_input_id = "#{builder.custom_namespace}_#{check_box_input_id}" unless builder.custom_namespace.blank?
                
                template.content_tag(:li,
                  template.content_tag(:label,
                    hidden_fields? ? 
                      check_box_with_hidden_input(check_box_value, check_box_input_id) : 
                      check_box_without_hidden_input(check_box_value, check_box_input_id) <<
                    check_box_label,
                    label_html_options.merge(:for => check_box_input_id)
                  ),
                  :class => value_as_class? ? "#{sanitized_method_name.singularize}_#{html_safe_value}" : ''
                )
              }.join("\n").html_safe
            )
          )
        end
      end
      
      def hidden_field_for_all
        if hidden_fields?
          ""
        else
          options = {}
          options[:class] = [method.to_s.singularize, 'default'].join('_') if value_as_class?
          options[:id] = [object_name, method, 'none'].join('_')
          template.hidden_field_tag(input_name, '', options)
        end
      end
      
      def legend_html
        if render_label?
          template.content_tag(:legend,
            template.content_tag(:label, label_text),
            label_html_options.merge(:class => "label")
          )
        else
          ""
        end
      end
      
      def value_as_class?
        options[:value_as_class]
      end
      
      def hidden_fields?
        options[:hidden_fields]
      end
      
      def check_box_with_hidden_input(value, check_box_input_id)
        builder.check_box(
          association_primary_key || method, 
          input_html_options.merge(:id => check_box_input_id, :name => input_name, :disabled => disabled?(value)), 
          value, 
          unchecked_value
        )
      end
      
      def check_box_without_hidden_input(value, check_box_input_id)
        template.check_box_tag(
          input_name, 
          value, 
          checked?(value), 
          input_html_options.merge(:id => check_box_input_id, :disabled => disabled?(value))
        ) 
      end
      
      def checked?(value)
        selected_values.include?(value)
      end
      
      def disabled?(value)
        disabled_values.include?(value)
      end
      
      def selected_values
        if object.respond_to?(method)
          selected_items = [object.send(method)].compact.flatten
          [*selected_items.map { |o| send_or_call(value_method, o) }].compact
        else
          []
        end
      end
      
      def disabled_values
        vals = options[:disabled] || []
        vals = [vals] unless vals.is_a?(Array)
        vals
      end
      
      def unchecked_value
        options[:unchecked_value] || ''
      end
      
      # Override to remove the for attribute since this isn't associated with any element, as it's
      # nested inside the legend.
      def label_html_options
        super.merge(:for => nil)
      end
      
      def input_name
        "#{object_name}[#{association_primary_key || method}][]"
      end
      
    end
  end
end