require 'support/base'

module Formtastic
  module Inputs
    module RadioInput
      include Support::Base
      
      # Outputs a fieldset containing a legend for the label text, and an ordered list (ol) of list
      # items, one for each possible choice in the belongs_to association.  Each li contains a
      # label and a radio input.
      #
      # Example:
      #
      #   f.input :author, :as => :radio
      #
      # Output:
      #
      #   <fieldset>
      #     <legend><span>Author</span></legend>
      #     <ol>
      #       <li>
      #         <label for="book_author_id_1"><input id="book_author_id_1" name="book[author_id]" type="radio" value="1" /> Justin French</label>
      #       </li>
      #       <li>
      #         <label for="book_author_id_2"><input id="book_author_id_2" name="book[owner_id]" type="radio" value="2" /> Kate French</label>
      #       </li>
      #     </ol>
      #   </fieldset>
      #
      # You can customize the choices available in the radio button set by passing in a collection (an Array or
      # Hash) through the :collection option.  If not provided, the choices are found by reflecting on the association
      # (Author.all in the example above).
      #
      # Examples:
      #
      #   f.input :author, :as => :radio, :collection => @authors
      #   f.input :author, :as => :radio, :collection => Author.all
      #   f.input :author, :as => :radio, :collection => [@justin, @kate]
      #   f.input :author, :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
      #
      # The :label_method option allows you to customize the label for each radio button two ways:
      #
      # * by naming the correct method to call on each object in the collection as a symbol (:name, :login, etc)
      # * by passing a Proc that will be called on each object in the collection, allowing you to use helpers or multiple model attributes together
      #
      # Examples:
      #
      #   f.input :author, :as => :radio, :label_method => :full_name
      #   f.input :author, :as => :radio, :label_method => :login
      #   f.input :author, :as => :radio, :label_method => :full_name_with_post_count
      #   f.input :author, :as => :radio, :label_method => Proc.new { |a| "#{a.name} (#{pluralize("post", a.posts.count)})" }
      #
      # The :value_method option provides the same customization of the value attribute of each option tag.
      #
      # Examples:
      #
      #   f.input :author, :as => :radio, :value_method => :full_name
      #   f.input :author, :as => :radio, :value_method => :login
      #   f.input :author, :as => :radio, :value_method => Proc.new { |a| "author_#{a.login}" }
      #
      # Finally, you can set :value_as_class => true if you want the li wrapper around each radio
      # button / label combination to contain a class with the value of the radio button (useful for
      # applying specific CSS or Javascript to a particular radio button).
      def radio_input(method, options)
        collection   = find_collection_for_column(method, options)
        html_options = strip_formtastic_options(options).merge(options.delete(:input_html) || {})
  
        input_name = generate_association_input_name(method)
        value_as_class = options.delete(:value_as_class)
        input_ids = []
  
        list_item_content = collection.map do |c|
          label = c.is_a?(Array) ? c.first : c
          value = c.is_a?(Array) ? c.last  : c
          input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
          input_ids << input_id
  
          html_options[:id] = input_id
  
          li_content = template.content_tag(:label,
            Formtastic::Util.html_safe("#{radio_button(input_name, value, html_options)} #{escape_html_entities(label)}"),
            :for => input_id
          )
  
          li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
          template.content_tag(:li, Formtastic::Util.html_safe(li_content), li_options)
        end
  
        template.content_tag(:fieldset,
          legend_tag(method, options) << template.content_tag(:ol, Formtastic::Util.html_safe(list_item_content.join))
        )
      end
    end
  end
end