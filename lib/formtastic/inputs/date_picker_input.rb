# frozen_string_literal: true
module Formtastic
  module Inputs
    
    # Outputs a simple `<label>` with a HTML5 `<input type="date">` wrapped in the standard
    # `<li>` wrapper. This is an alternative to `:date_select` for `:date`, `:time`, `:datetime` 
    # database columns. You can use this input with `:as => :date_picker`.
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
    #       <%= f.input :publish_at, :as => :date_picker %>
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
    # @example Setting the size (defaults to 10 for YYYY-MM-DD)
    #   <%= f.input :publish_at, :as => :date_picker, :size => 20 %>
    #   <%= f.input :publish_at, :as => :date_picker, :input_html => { :size => 20 } %>
    #
    # @example Setting the maxlength (defaults to 10 for YYYY-MM-DD)
    #   <%= f.input :publish_at, :as => :date_picker, :maxlength => 20 %>
    #   <%= f.input :publish_at, :as => :date_picker, :input_html => { :maxlength => 20 } %>
    #
    # @example Setting the value (defaults to YYYY-MM-DD for Date and Time objects, otherwise renders string)
    #   <%= f.input :publish_at, :as => :date_picker, :input_html => { :value => "1970-01-01" } %>
    #
    # @example Setting the step attribute (defaults to 1)
    #   <%= f.input :publish_at, :as => :date_picker, :step => 7 %>
    #   <%= f.input :publish_at, :as => :date_picker, :input_html => { :step => 7 } %>
    #
    # @example Setting the step attribute with a macro
    #   <%= f.input :publish_at, :as => :date_picker, :step => :day %>
    #   <%= f.input :publish_at, :as => :date_picker, :step => :week %>
    #   <%= f.input :publish_at, :as => :date_picker, :step => :seven_days %>
    #   <%= f.input :publish_at, :as => :date_picker, :step => :fortnight %>
    #   <%= f.input :publish_at, :as => :date_picker, :step => :two_weeks %>
    #   <%= f.input :publish_at, :as => :date_picker, :step => :four_weeks %>
    #   <%= f.input :publish_at, :as => :date_picker, :step => :thirty_days %>
    #
    # @example Setting the min attribute
    #   <%= f.input :publish_at, :as => :date_picker, :min => "2012-01-01" %>
    #   <%= f.input :publish_at, :as => :date_picker, :input_html => { :min => "2012-01-01" } %>
    #
    # @example Setting the max attribute
    #   <%= f.input :publish_at, :as => :date_picker, :max => "2012-12-31" %>
    #   <%= f.input :publish_at, :as => :date_picker, :input_html => { :max => "2012-12-31" } %>
    #
    # @example Setting the placeholder attribute
    #   <%= f.input :publish_at, :as => :date_picker, :placeholder => 20 %>
    #   <%= f.input :publish_at, :as => :date_picker, :input_html => { :placeholder => "YYYY-MM-DD" } %>
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documentation of all possible options.
    class DatePickerInput
      include Base
      include Base::Stringish
      include Base::DatetimePickerish
      
      def html_input_type
        "date"
      end
      
      def default_size
        10
      end
      
      def value
        return options[:input_html][:value] if options[:input_html] && options[:input_html].key?(:value)
        val = object.send(method)
        return Date.new(val.year, val.month, val.day).to_s if val.is_a?(Time)
        return val if val.nil?
        val.to_s
      end
      
    end
  end
end