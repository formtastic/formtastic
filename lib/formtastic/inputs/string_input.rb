module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a `<input type="text">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for database columns of the `:string` type,
    # and is the default choice for all inputs when no other logical input type can be inferred.
    # You can force any input to be a string input with `:as => :string`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :first_name, :as => :string %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="string">
    #           <label for="user_first_name">First name</label>
    #           <input type="text" id="user_first_name" name="user[first_name]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module StringInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Basic

      def string_input(method, options)
        basic_input_helper(:text_field, :string, method, options)
      end
    end
  end
end