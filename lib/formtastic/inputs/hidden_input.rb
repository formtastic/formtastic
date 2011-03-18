require 'inputs/new_base'

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
    class HiddenInput 
      include NewBase
      
      def input_html_options
        super[:id] = super[:id].gsub(/_id$/, '') # TODO: special case because we seem to test hidden input differently
        return {:value => options[:value]}.merge(super) if options.key?(:value)
        super
      end
      
      def to_html
        input_wrapping do
          builder.hidden_field(method, input_html_options)
        end
      end
      
      def error_html
        ""
      end
      
      def errors?
        false
      end
      
      def hint_html
        ""
      end
      
      def hint?
        false
      end

    end
  end
end