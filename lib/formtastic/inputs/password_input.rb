module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a `<input type="password">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for all attributes matching `/password/`, but
    # can be applied to any text-like input with `:as => :password`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :password, :as => :password %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="password">
    #           <label for="user_password">Password</label>
    #           <input type="password" id="user_password" name="user[password]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module PasswordInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Basic

      # Outputs a label and standard Rails password field inside the wrapper.
      def password_input(method, options)
        basic_input_helper(:password_field, :password, method, options)
      end
    end
  end
end