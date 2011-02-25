module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a HTML5 `<input type="email">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for attributes with a name matching
    # `/email/`, but can be applied to any text-like input with `:as => :email`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :email_address, :as => :email %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="email">
    #           <label for="user_email_address">Email address</label>
    #           <input type="email" id="user_email_address" name="user[email_address]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module EmailInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Basic

      def email_input(method, options)
        basic_input_helper(:email_field, :email, method, options)
      end
    end
  end
end