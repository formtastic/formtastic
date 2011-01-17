require 'inputs/base'

module Formtastic
  module Inputs
    module CheckBoxesInput
      include Formtastic::Inputs::Base
      
      # Outputs a fieldset containing a legend for the label text, and an ordered list (ol) of list
      # items, one for each possible choice in the belongs_to association.  Each li contains a
      # label and a check_box input.
      #
      # This is an alternative for has many and has and belongs to many associations.
      #
      # Example:
      #
      #   f.input :author, :as => :check_boxes
      #
      # Output:
      #
      #   <fieldset>
      #     <legend class="label"><label>Authors</label></legend>
      #     <ol>
      #       <li>
      #         <input type="hidden" name="book[author_id][1]" value="">
      #         <label for="book_author_id_1"><input id="book_author_id_1" name="book[author_id][1]" type="checkbox" value="1" /> Justin French</label>
      #       </li>
      #       <li>
      #         <input type="hidden" name="book[author_id][2]" value="">
      #         <label for="book_author_id_2"><input id="book_author_id_2" name="book[owner_id][2]" type="checkbox" value="2" /> Kate French</label>
      #       </li>
      #     </ol>
      #   </fieldset>
      #
      # Notice that the value of the checkbox is the same as the id and the hidden
      # field has empty value. You can override the hidden field value using the
      # unchecked_value option.
      #
      # You can customize the options available in the set by passing in a collection (Array) of
      # ActiveRecord objects through the :collection option.  If not provided, the choices are found
      # by inferring the parent's class name from the method name and simply calling all on
      # it (Author.all in the example above).
      #
      # Examples:
      #
      #   f.input :author, :as => :check_boxes, :collection => @authors
      #   f.input :author, :as => :check_boxes, :collection => Author.all
      #   f.input :author, :as => :check_boxes, :collection => [@justin, @kate]
      #
      # The :label_method option allows you to customize the label for each checkbox two ways:
      #
      # * by naming the correct method to call on each object in the collection as a symbol (:name, :login, etc)
      # * by passing a Proc that will be called on each object in the collection, allowing you to use helpers or multiple model attributes together
      #
      # Examples:
      #
      #   f.input :author, :as => :check_boxes, :label_method => :full_name
      #   f.input :author, :as => :check_boxes, :label_method => :login
      #   f.input :author, :as => :check_boxes, :label_method => :full_name_with_post_count
      #   f.input :author, :as => :check_boxes, :label_method => Proc.new { |a| "#{a.name} (#{pluralize("post", a.posts.count)})" }
      #
      # The :value_method option provides the same customization of the value attribute of each checkbox input tag.
      #
      # Examples:
      #
      #   f.input :author, :as => :check_boxes, :value_method => :full_name
      #   f.input :author, :as => :check_boxes, :value_method => :login
      #   f.input :author, :as => :check_boxes, :value_method => Proc.new { |a| "author_#{a.login}" }
      #
      # Formtastic works around a bug in rails handling of check box collections by
      # not generating the hidden fields for state checking of the checkboxes
      # The :hidden_fields option provides a way to re-enable these hidden inputs by
      # setting it to true.
      #
      #   f.input :authors, :as => :check_boxes, :hidden_fields => false
      #   f.input :authors, :as => :check_boxes, :hidden_fields => true
      #
      # Finally, you can set :value_as_class => true if you want the li wrapper around each checkbox / label
      # combination to contain a class with the value of the radio button (useful for applying specific
      # CSS or Javascript to a particular checkbox).
      #
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
  
      # Outputs a checkbox tag. If called with no_hidden_input = true a plain check_box_tag is returned,
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