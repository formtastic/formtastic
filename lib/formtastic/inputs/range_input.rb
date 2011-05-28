module Formtastic
  module Inputs
    
    # Outputs a simple `<label>` with a HTML5 `<input type="range">` wrapped in the standard
    # `<li>` wrapper. This is an alternative input choice to a number input.
    #
    # Sensible default for the `min`, `max` and `step` attributes are found by reflecting on 
    # the model's validations. When validations are not provided, the `min` and `step` default to
    # `1` and the `max` default to `100`. An `IndeterminableMinimumAttributeError` exception 
    # will be raised when the following conditions are all true:
    #
    # * you haven't specified a `:min` or `:max` for the input
    # * the model's database column type is a `:float` or `:decimal`
    # * the validation uses `:less_than` or `:greater_than`
    #
    # The solution is to either:
    # 
    # * manually specify the `:min` or `:max` for the input
    # * change the database column type to an `:integer` (if appropriate)
    # * change the validations to use `:less_than_or_equal_to` or `:greater_than_or_equal_to`
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :shoe_size, :as => :range %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="numeric">
    #           <label for="user_shoe_size">Shoe size</label>
    #           <input type="range" id="user_shoe_size" name="user[shoe_size]" min="1" max="100" step="1">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @example Default HTML5 min/max/step attributes are detected from the numericality validations
    #
    #   class Person < ActiveRecord::Base
    #     validates_numericality_of :age, 
    #       :less_than_or_equal_to => 100, 
    #       :greater_than_or_equal_to => 18, 
    #       :only_integer => true
    #   end
    #
    #   <%= f.input :age, :as => :number %>
    #
    #   <li class="numeric">
    #     <label for="persom_age">Age</label>
    #     <input type="range" id="person_age" name="person[age]" min="18" max="100" step="1">
    #   </li>
    #
    # @example Pass attributes down to the `<input>` tag with :input_html
    #  <%= f.input :shoe_size, :as => :range, :input_html => { :min => 3, :max => 15, :step => 1, :class => "special" } %>
    #
    # @example Min/max/step also work as options
    #  <%= f.input :shoe_size, :as => :range, :min => 3, :max => 15, :step => 1, :input_html => { :class => "special" } %>
    #
    # @example Use :in with a Range as a shortcut for :min/:max
    #  <%= f.input :shoe_size, :as => :range, :in => 3..15, :step => 1 %>
    #  <%= f.input :shoe_size, :as => :range, :input_html => { :in => 3..15, :step => 1 } %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    # @see http://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html#method-i-validates_numericality_of Rails' Numericality validation documentation
    #
    # @todo Is it still correct for this to be Stringish?
    class RangeInput
      include Base
      include Base::Stringish

      def to_html
        input_wrapping do
          label_html <<
          builder.range_field(method, input_html_options)
        end
      end
      
      def input_html_options
        defaults = super
        
        if in_option
          defaults[:min] = in_option.to_a.min
          defaults[:max] = in_option.to_a.max
        else
          defaults[:min]  ||= min_option
          defaults[:max]  ||= max_option
        end
        defaults[:step] ||= step_option
        defaults
      end
      
      def step_option
        return options[:step] if options.key?(:step)
        return validation_step if validation_step
        return 1 if validation_integer_only?
        1
      end
      
      def min_option
        return options[:min] if options.key?(:min)
        validation_min || 1
      end
      
      def max_option
        return options[:max] if options.key?(:max)
        validation_max || 100
      end
      
      def in_option
        options[:in]
      end
      
    end
  end
end