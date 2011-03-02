require 'inputs/new_base'

module Formtastic
  module Inputs
    
    # Outputs a simple `<label>` with a `<input type="file">` wrapped in the standard
    # `<li>` wrapper. This is the default input choice for objects with attributes that appear
    # to be for file uploads, by detecting some common method names used by popular file upload
    # libraries such as Paperclip and CarrierWave. You can add to or alter these method names 
    # through the `file_methods` config, but can be applied to any input with `:as => :file`.
    #
    # Don't forget to set the multipart attribute in your `<form>` tag!
    #
    # @example Full form context and output
    # 
    #   <%= semantic_form_for(@user, :html => { :multipart => true }) do |f| %>
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
    class FileInput < NewBase
      def to_html
        input_wrapping do
          builder.label(method, label_html_options) <<
          builder.file_field(method, input_html_options)
        end
      end
    end
  end
end