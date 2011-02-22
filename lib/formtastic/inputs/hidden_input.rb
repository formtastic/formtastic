module Formtastic
  module Inputs
    
    # Outputs a simple `<input type="hidden">` wrapped in the standard `<li>` wrapper. This is
    # provided for situations where a hidden field needs to be rendered in the flow of a form with
    # many inputs that form an `<ol>`. Wrapping the hidden input inside the `<li>` maintains the 
    # HTML validity. The `<li>` is marked with a `class` of `hidden` so that stylesheet authors can
    # hide these list items with CSS (formtastic.css does this out of the box).
    # 
    # @example Full form context, output and CSS
    # 
    #   <%= semantic_form_for(@something) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :secret, :as => :hidden %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="hidden">
    #           <input type="hidden" id="something_secret" name="something[secret]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    #   form.formtastic li.hidden { display:none; }
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module HiddenInput
      include Formtastic::Inputs::Base
      
      def hidden_input(method, options)
        options ||= {}
        html_options = options.delete(:input_html) || strip_formtastic_options(options)
        html_options[:id] ||= generate_html_id(method, "")
        hidden_field(method, html_options)
      end
    end
  end
end