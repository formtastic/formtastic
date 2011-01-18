module Formtastic
  module Inputs
    module Timeish
      # Helper method used by :as => (:date|:datetime|:time).  Generates a fieldset containing a
      # legend (for what would normally be considered the label), and an ordered list of list items
      # for year, month, day, hour, etc, each containing a label and a select.  Example:
      #
      # <fieldset>
      #   <legend>Created At</legend>
      #   <ol>
      #     <li>
      #       <label for="user_created_at_1i">Year</label>
      #       <select id="user_created_at_1i" name="user[created_at(1i)]">
      #         <option value="2003">2003</option>
      #         ...
      #         <option value="2013">2013</option>
      #       </select>
      #     </li>
      #     <li>
      #       <label for="user_created_at_2i">Month</label>
      #       <select id="user_created_at_2i" name="user[created_at(2i)]">
      #         <option value="1">January</option>
      #         ...
      #         <option value="12">December</option>
      #       </select>
      #     </li>
      #     <li>
      #       <label for="user_created_at_3i">Day</label>
      #       <select id="user_created_at_3i" name="user[created_at(3i)]">
      #         <option value="1">1</option>
      #         ...
      #         <option value="31">31</option>
      #       </select>
      #     </li>
      #   </ol>
      # </fieldset>
      #
      # This is an absolute abomination, but so is the official Rails select_date().
      #
      # Options:
      #
      #   * @:order => [:month, :day, :year]@
      #   * @:include_seconds@ => true@
      #   * @:discard_(year|month|day|hour|minute) => true@
      #   * @:include_blank => true@
      #   * @:labels => {}@
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
      def field_set_and_list_wrapping_for_method(method, options, contents) #:nodoc:
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