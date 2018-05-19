module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a `<input type="text">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for database columns of the `:jsonb` type.
    # You can force any input to be a string input with `:as => :json`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :preferences, :as => :json %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="string">
    #           <label for="user_preferences">Preferences</label>
    #           <input type="text" id="user_preferences" name="user[preferences]" value="{\"preference1\":\"value1\"}">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.

    class JsonInput < StringInput
      def to_html
        val = self.object.send(method)
        self.object.send("#{method}=", JSON.generate(val))
        super
      end
    end
  end
end
