module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a HTML5 `<input type="number">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for all database columns of the type `:float`
    # and `:decimal`, as well as `:integer` columns that aren't used for `belongs_to` associations,
    # but can be applied to any text-like input with `:as => :number`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :shoe_size, :as => :number %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="numeric">
    #           <label for="user_shoe_size">Shoe size</label>
    #           <input type="number" id="user_shoe_size" name="user[shoe_size]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @example Default HTML5 min/max/step attributes are detected from the numericality validations
    #
    #   class Person < ActiveRecord::Base
    #     validates_numericality_of :age, 
    #       :less_than => 100, 
    #       :greater_than => 17, 
    #       :only_integer => true
    #   end
    #
    #   <%= f.input :age, :as => :number %>
    #
    #   <li class="numeric">
    #     <label for="persom_age">Age</label>
    #     <input type="number" id="person_age" name="person[age]" min="18" max="99" step="1">
    #   </li>
    #
    # @example Pass attributes down to the `<input>` tag
    #  <%= f.input :shoe_size, :as => :number, :input_html => { :min => 3, :max => 15, :step => 1, :class => "special" } %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    # @see http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html#method-i-validates_numericality_of Rails' Numericality validation documentation
    #
    # @todo Rename/Alias to NumberInput
    class NumberInput 
      include Base
      include Base::Stringish
      
      def to_html
        input_wrapping do
          label_html <<
          builder.number_field(method, input_html_options)
        end
      end
      
      def input_html_options
        {
          :min => validation_min,
          :max => validation_max,
          :step => validation_integer_only? ? 1 : nil 
        }.merge(super)
      end
      
    end
  end
end