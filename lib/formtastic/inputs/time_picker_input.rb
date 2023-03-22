# frozen_string_literal: true
module Formtastic
  module Inputs
    
    # Outputs a simple `<label>` with a HTML5 `<input type="time">` wrapped in the standard
    # `<li>` wrapper. This is an alternative to `:time_select` for `:date`, `:time`, `:datetime` 
    # database columns. You can use this input with `:as => :time_picker`.
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
    #       <%= f.input :publish_at, :as => :time_picker %>
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
    # @example Setting the size (defaults to 5 for HH:MM)
    #   <%= f.input :publish_at, :as => :time_picker, :size => 20 %>
    #   <%= f.input :publish_at, :as => :time_picker, :input_html => { :size => 20 } %>
    #
    # @example Setting the maxlength (defaults to 5 for HH:MM)
    #   <%= f.input :publish_at, :as => :time_picker, :maxlength => 20 %>
    #   <%= f.input :publish_at, :as => :time_picker, :input_html => { :maxlength => 20 } %>
    #
    # @example Setting the value (defaults to HH:MM for Date and Time objects, otherwise renders string)
    #   <%= f.input :publish_at, :as => :time_picker, :input_html => { :value => "14:14" } %>
    #
    # @example Setting the step attribute (defaults to 60)
    #   <%= f.input :publish_at, :as => :time_picker, :step => 120 %>
    #   <%= f.input :publish_at, :as => :time_picker, :input_html => { :step => 120 } %>
    #
    # @example Setting the step attribute with a macro
    #   <%= f.input :publish_at, :as => :time_picker, :step => :second %>
    #   <%= f.input :publish_at, :as => :time_picker, :step => :minute %>
    #   <%= f.input :publish_at, :as => :time_picker, :step => :quarter_hour %>
    #   <%= f.input :publish_at, :as => :time_picker, :step => :fifteen_minutes %>
    #   <%= f.input :publish_at, :as => :time_picker, :step => :half_hour %>
    #   <%= f.input :publish_at, :as => :time_picker, :step => :thirty_minutes %>
    #   <%= f.input :publish_at, :as => :time_picker, :step => :hour %>
    #   <%= f.input :publish_at, :as => :time_picker, :step => :sixty_minutes %>
    #
    # @example Setting the min attribute
    #   <%= f.input :publish_at, :as => :time_picker, :min => "09:00" %>
    #   <%= f.input :publish_at, :as => :time_picker, :input_html => { :min => "01:00" } %>
    #
    # @example Setting the max attribute
    #   <%= f.input :publish_at, :as => :time_picker, :max => "18:00" %>
    #   <%= f.input :publish_at, :as => :time_picker, :input_html => { :max => "18:00" } %>
    #
    # @example Setting the placeholder attribute
    #   <%= f.input :publish_at, :as => :time_picker, :placeholder => "HH:MM" %>
    #   <%= f.input :publish_at, :as => :time_picker, :input_html => { :placeholder => "HH:MM" } %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    class TimePickerInput
      include Base
      include Base::Stringish
      include Base::DatetimePickerish
      
      def html_input_type
        "time"
      end
      
      def default_size
        5
      end
      
      def value
        return options[:input_html][:value] if options[:input_html] && options[:input_html].key?(:value)
        val = object.send(method)
        return "00:00" if val.is_a?(Date)
        return val.strftime("%H:%M") if val.is_a?(Time)
        return val if val.nil?
        val.to_s
      end
      
      def default_step
        60
      end
      
    end
  end
end