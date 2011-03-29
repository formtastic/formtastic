module Formtastic
  module Inputs

    # Outputs a `<label>` with a `<select>` containing a series of time zones (using Rails' own
    # `time_zone_select` helper), wrapped in the standard `<li>` wrapper.

    # This is the default input choice for attributes matching /time_zone/, but can be applied to
    # any text-like input with `:as => :time_zone`.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@user) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :time_zone, :as => :time_zone %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="time_zone">
    #           <label for="user_time_zone">Time zone</label>
    #           <input type="text" id="user_time_zone" name="user[time_zone]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.

    module TimeZoneInput
      def time_zone_input(method, options)
        html_options = options.delete(:input_html) || {}
        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]
        label(method, label_options) <<
        time_zone_select(method, options.delete(:priority_zones),
          strip_formtastic_options(options), html_options)
      end
    end
  end
end