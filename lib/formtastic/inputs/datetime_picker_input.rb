module Formtastic
  module Inputs
    
    # Outputs a simple `<label>` with a HTML5 `<input type="datetime-local">` (or 
    # `<input type="datetime">`) wrapped in the standard `<li>` wrapper. This is an alternative to 
    # `:date_select` for `:date`, `:time`, `:datetime` database columns. You can use this input with
    # `:as => :datetime_picker`.
    #
    # *Please note:* Formtastic only provides suitable markup for a date picker, but does not supply
    # any additional CSS or Javascript to render calendar-style date pickers. Browsers that support
    # this input type (such as Mobile Webkit and Opera on the desktop) will render a native widget.
    # Browsers that don't will default to a plain text field`<input type="text">` and can be 
    # poly-filled with some Javascript and a UI library of your choice.
    #
    # @example Full form context and output
    #
    #   <%= semantic_form_for(@post) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :publish_at, :as => :datetime_picker %>
    #     <% end %>
    #   <% end %>
    #
    #   <form...>
    #     <fieldset>
    #       <ol>
    #         <li class="string">
    #           <label for="post_publish_at">First name</label>
    #           <input type="date" id="post_publish_at" name="post[publish_at]">
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @example Setting the size (defaults to 16 for YYYY-MM-DD HH:MM)
    #   <%= f.input :publish_at, :as => :datetime_picker, :size => 20 %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :input_html => { :size => 20 } %>
    #
    # @example Setting the maxlength (defaults to 16 for YYYY-MM-DD HH:MM)
    #   <%= f.input :publish_at, :as => :datetime_picker, :maxlength => 20 %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :input_html => { :maxlength => 20 } %>
    #
    # @example Setting the value (defaults to YYYY-MM-DD HH:MM for Date and Time objects, otherwise renders string)
    #   <%= f.input :publish_at, :as => :datetime_picker, :input_html => { :value => "1970-01-01 00:00" } %>
    #
    # @example Setting the step attribute (defaults to 1)
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => 60 %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :input_html => { :step => 60 } %>
    #
    # @example Setting the step attribute with a macro
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :second %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :minute %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :quarter_hour %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :fifteen_minutes %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :half_hour %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :thirty_minutes %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :hour %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :step => :sixty_minutes %>
    #
    # @example Setting the min attribute
    #   <%= f.input :publish_at, :as => :datetime_picker, :min => "2012-01-01 09:00" %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :input_html => { :min => "2012-01-01 09:00" } %>
    #
    # @example Setting the max attribute
    #   <%= f.input :publish_at, :as => :datetime_picker, :max => "2012-12-31 16:00" %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :input_html => { :max => "2012-12-31 16:00" } %>
    #
    # @example Setting the placeholder attribute
    #   <%= f.input :publish_at, :as => :datetime_picker, :placeholder => "YYYY-MM-DD HH:MM" %>
    #   <%= f.input :publish_at, :as => :datetime_picker, :input_html => { :placeholder => "YYYY-MM-DD HH:MM" } %>
    #
    # @example Using `datetime` (UTC) or `datetime-local` with `:local` (defaults to true, `datetime-local` input)
    #   <%= f.input :publish_at, :as => :datetime_picker, :local => false %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    class DatetimePickerInput
      include Base
      include Base::Stringish
      include Base::DatetimePickerish
      
      def html_input_type
        options[:local] = true unless options.key?(:local)
        options[:local] ? "datetime-local" : "datetime"
      end
      
      def default_size
        16
      end
      
      def value
        return options[:input_html][:value] if options[:input_html] && options[:input_html].key?(:value)
        val = object.send(method)
        return val.strftime("%Y-%m-%dT%H:%M:%S") if val.is_a?(Time)
        return "#{val.year}-#{val.month}-#{val.day}T00:00:00" if val.is_a?(Date)
        return val if val.nil?
        val.to_s
      end
      
    end
  end
end
