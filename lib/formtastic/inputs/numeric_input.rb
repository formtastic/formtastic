require 'inputs/basic'

module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a HTML5 `<input type="number">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for all database columns of the type `:float`
    # and `:decimal`, as well as `:integer` columns that aren't used for `belongs_to` associations`,
    # but can be applied to any text-like input with `:as => :numeric`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :shoe_size, :as => :numeric %>
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
    # @example Pass new HTML5 attrbutes down to the `<input>` tag
    #  <%= f.input :shoe_size, :as => :numeric, :input_html => { :min => 3, :max => 15, :step => 1 } %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    class NumericInput 
      include Base
      include Base::Stringish
      
      def to_html
        input_wrapping do
          label_html <<
          builder.number_field(method, input_html_options)
        end
      end

      # Outputs a label and standard Rails text field inside the wrapper.
      def numeric_input(method, options)
        basic_input_helper(:number_field, :numeric, method, range_options_for(method, options))
      end
    end
  end
end
