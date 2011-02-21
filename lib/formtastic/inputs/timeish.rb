module Formtastic
  module Inputs

    # Outputs a complex input consisting of multiple select boxes for each fragment of a date 
    # (year, month, day), time (hour, min, sec) or date time (year, month, day, hour, min, sec).
    #
    # The output of this helper **looks** quite similar to Rails' own `date_select`, 
    # `date_time_select` and `time_select` helpers in the browser, but under the hood the HTML 
    # produced is quite different, trying to address many issues with the Rails helper's HTML 
    # validity, semantics and accessibility.
    #
    # By default, Rails will return a series of `<select>` tags without a corresponding `<label>`
    # for each. Formtastic chooses to rendering these date fragments much like it does each form
    # input by wrapping each in an `<li>` with a `<label>` and a `<select>` in each.
    #
    # The `<li>` date fragments are wrapped in an `<ol>` and a `<fieldset>` to indicate that the
    # fragments are part of a set of fields that should be grouped together.
    #
    # The `<fieldset>` is then "labeled" with a `<legend>` tag that describes the set with the 
    # same string that would normally be used for the `<label>` on a simpler input. The result
    # is something like this:
    #
    #     <li class="date">
    #       <fieldset>
    #         <legend class="label">Publish at</legend>
    #         <ol>
    #           <li>
    #             <label for="user_created_at_1i">Year</label>
    #             <select id="user_created_at_1i" name="user[created_at(1i)]">
    #               <option value="2003">2003</option>
    #               ...
    #               <option value="2013">2013</option>
    #             </select>
    #           </li>
    #           <li>
    #             <label for="user_created_at_2i">Month</label>
    #             <select id="user_created_at_2i" name="user[created_at(2i)]">
    #               <option value="1">January</option>
    #               ...
    #               <option value="12">December</option>
    #             </select>
    #           </li>
    #           <li>
    #             <label for="user_created_at_3i">Day</label>
    #             <select id="user_created_at_3i" name="user[created_at(3i)]">
    #               <option value="1">1</option>
    #               ...
    #               <option value="31">31</option>
    #             </select>
    #           </li>
    #         </ol>
    #       </fieldset>
    #     </li>
    #
    # This obviously would look quite different in a browser to what Rails does, but this is
    # addressed in the presentation layer with formtastic.css instead:
    #
    # * the `<li>` date fragments are floated left against each other so they appear all on one 
    #   line next to each other
    # * the `<label>` tags for each fragment are hidden with `display:none`
    # * the <legend> is positioned and styled to look like a regular `<label>` on simpler inputs
    #   found elsewhere in the form (to the left of the select tags)
    # * the `<ol>` is positioned and styled to appear where the `<input>` would usually be on 
    #   simpler inputs found elsewhere in the form (the the right of the label), as a container
    #   for the floated `<li>` fragments
    #
    # The intent is to support many of Rails' built-in date helper arguments and options, and 
    # to post the same form data to your controllers.
    #
    # @example Basic `:date` example with full form context and output
    # 
    #   <%= semantic_form_for(@post) do |f| %>
    #     <%= f.inputs do %>
    #       <%= f.input :publish_at, :as => :date %>
    #     <% end %>
    #   <% end %<
    #
    #   <form ...>
    #     <fieldset>
    #       <ol>
    #         <li class="date">
    #           <fieldset>
    #             <legend class="label">Publish at</legend>
    #             <ol>
    #               <li>
    #                 <label for="user_created_at_1i">Year</label>
    #                 <select id="user_created_at_1i" name="user[created_at(1i)]">
    #                   <option value="2003">2003</option>
    #                   ...
    #                   <option value="2013">2013</option>
    #                 </select>
    #               </li>
    #               <li>
    #                 <label for="user_created_at_2i">Month</label>
    #                 <select id="user_created_at_2i" name="user[created_at(2i)]">
    #                   <option value="1">January</option>
    #                   ...
    #                   <option value="12">December</option>
    #                 </select>
    #               </li>
    #               <li>
    #                 <label for="user_created_at_3i">Day</label>
    #                 <select id="user_created_at_3i" name="user[created_at(3i)]">
    #                   <option value="1">1</option>
    #                   ...
    #                   <option value="31">31</option>
    #                 </select>
    #               </li>
    #             </ol>
    #           </fieldset>
    #         </li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # @example Render as a `:date` (default for `:date` database column types)
    #   <%= f.input :publish_at, :as => :date %>
    #
    # @example Render as a `:datetime` input (default for `:datetime` and `:timestamp` database column types)
    #   <%= f.input :publish_at, :as => :datetime %>
    #
    # @example Render as a `:time` input (default for `:time` database column types)
    #   <%= f.input :publish_at, :as => :time %>
    #
    # @example Re-order the date fragments with `:order`
    #   <%= f.input :publish_at, :as => :date, :order => [:day, :month, :year] %>
    #   <%= f.input :publish_at, :as => :datetime, :order => [:hour, :min, :day, :month, :year] %>
    #
    # @example Render the (discarded by default) seconds fragment with `:include_seconds` (`:time`, `:datetime` only)
    #   <%= f.input :publish_at, :as => :datetime, :include_seconds => true %>
    #
    # @example `:discard_(year|month|day|hour|minute)` can be set to true to exclude those fragments (Rails will default them)
    #   <%= f.input :publish_at, :as => :datetime, :discard_minute => true %>
    #   <%= f.input :publish_at, :as => :date, :discard_day => true %>
    #
    # @example Render a blank option at the top of each fragment's select to force the user to make a choice
    #   <%= f.input :publish_at, :as => :datetime, :include_blank => true %>
    #
    # @example Change the labels used for each fragment
    #   <%= f.input :publish_at, :as => :datetime, :labels => { :year => "The Year" } %>
    #
    # @example Disale the labels used for each fragment
    #   <%= f.input :publish_at, :as => :datetime, :labels => { :year => "", :month => "", :day => "" } %>
    #
    # @todo `:labels` could be killed and replaced with i18n
    # @todo is there i18n for `:labels` already?
    # @todo is there `:prompt`?
    # @todo is there any other i18n to document?
    #
    # @see Formtastic::Helpers::InputsHelper#input InputsHelper#input for full documetation of all possible options.
    module Timeish
      # Helper method used by :as => (:date|:datetime|:time).
      #
      # This is an absolute abomination, but so is the official Rails select_date().
      # @private
      def date_or_datetime_input(method, options)
        position = { :year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => 6 }
        i18n_date_order = ::I18n.t(:order, :scope => [:date])
        i18n_date_order = nil unless i18n_date_order.is_a?(Array)
        inputs   = options.delete(:order) || i18n_date_order || [:year, :month, :day]
        inputs   = [] if options[:ignore_date]
        labels   = options.delete(:labels) || {}
      
        time_inputs = [:hour, :minute]
        time_inputs << :second if options[:include_seconds]
      
        list_items_capture = ""
        hidden_fields_capture = ""
      
        datetime = @object.send(method) if @object && @object.send(method)
      
        html_options = options.delete(:input_html) || {}
        input_ids    = []
      
        (inputs + time_inputs).each do |input|
          input_ids << input_id = generate_html_id(method, "#{position[input]}i")
      
          field_name = "#{method}(#{position[input]}i)"
          if options[:"discard_#{input}"]
            break if time_inputs.include?(input)
      
            hidden_value = datetime.respond_to?(input) ? datetime.send(input) : datetime
            hidden_fields_capture << template.hidden_field_tag("#{@object_name}[#{field_name}]", (hidden_value || 1), :id => input_id)
          else
            opts = strip_formtastic_options(options).merge(:prefix => @object_name, :field_name => field_name, :default => datetime)
            item_label_text = labels[input] || ::I18n.t(input.to_s, :default => input.to_s.humanize, :scope => [:datetime, :prompts])
      
            list_items_capture << template.content_tag(:li, Formtastic::Util.html_safe([
                !item_label_text.blank? ? template.content_tag(:label, Formtastic::Util.html_safe(item_label_text), :for => input_id) : "",
                template.send(:"select_#{input}", datetime, opts, html_options.merge(:id => input_id))
              ].join(""))
            )
          end
        end
      
        hidden_fields_capture << field_set_and_list_wrapping_for_method(method, options.merge(:label_for => input_ids.first), list_items_capture)
      end
      
      # Generates a fieldset and an ordered list but with label based in
      # method. This methods is currently used by radio and datetime inputs.
      # @private
      def field_set_and_list_wrapping_for_method(method, options, contents)
        contents = contents.join if contents.respond_to?(:join)
  
        template.content_tag(:fieldset,
            template.content_tag(:legend,
                label(method, options_for_label(options).merge(:for => options.delete(:label_for))), :class => 'label'
              ) <<
            template.content_tag(:ol, Formtastic::Util.html_safe(contents))
          )
      end
  
    end
  end
end