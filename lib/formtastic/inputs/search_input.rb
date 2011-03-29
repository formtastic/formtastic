module Formtastic
  module Inputs

    # Outputs a simple `<label>` with a HTML5 `<input type="search">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for attributes with a name matching
    # `/^search$/`, but can be applied to any text-like input with `:as => :search`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@search, :html => { :method => :get }) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :q, :as => :search, :label => false, :input_html => { :name => "q" } %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="search">
    #           <input type="search" id="search_q" name="q">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module SearchInput
      include Formtastic::Inputs::Base
      include Formtastic::Inputs::Basic

      def search_input(method, options)
        basic_input_helper(:search_field, :search, method, options)
      end
    end
  end
end