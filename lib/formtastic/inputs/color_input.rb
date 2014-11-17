module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a HTML5 `<input type="color">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for attributes with a name matching
    # `/color/`, but can be applied to any text-like input with `:as => :color`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :color, :as => :color %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="color">
    #           <label for="user_color">Color</label>
    #           <input type="color" id="user_color" name="user[color]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    class ColorInput 
      include Base
      include Base::Stringish
      include Base::Placeholder
      
      def to_html
        input_wrapping do
          label_html <<
          builder.color_field(method, input_html_options)
        end
      end
    end
  end
end
