module JustinFrench #:nodoc:
  module Formtastic #:nodoc:
    
    # Defines a semantic_form_for wrapping around a standard form_for method with the
    # SemanticFormBuilder.
    # 
    # Example:
    #   
    #   <% semantic_form_for @article do %>
    #     ...
    #   <% end %>
    # 
    # TODO:
    # * semantic_fields_for
    # * semantic_form_remote_for
    # * semantic_remote_form_for
    module SemanticFormHelper
      
      def semantic_form_for(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        form_for(record_or_name_or_array, *(args << options.merge(:builder => JustinFrench::Formtastic::SemanticFormBuilder)), &proc)
      end
      
      # TODO
      #[:form_for, :fields_for, :form_remote_for, :remote_form_for].each do |meth|
      #  src = <<-END_SRC   
      #    def semantic_#{meth}(record_or_name_or_array, *args, &proc)
      #      options = args.extract_options!            
      #      #{meth}(record_or_name_or_array, *(args << options.merge(:builder => JustinFrench::Formtastic::SemanticFormBuilder)), &proc)
      #    end
      #  END_SRC
      #  module_eval src, __FILE__, __LINE__
      #end
    end
 
    
    class SemanticFormBuilder < ActionView::Helpers::FormBuilder
      
      DEFAULT_TEXT_FIELD_SIZE = 50
      
      @@all_fields_required_by_default = true
      @@required_string = %{<abbr title="required">*</abbr>}
      @@optional_string = ''
      
      cattr_accessor :all_fields_required_by_default, :required_string, :optional_string
      
      
      # Returns a suitable form input for the given +method+, using the database column information
      # and other factors (like the method name) to figure out what you probably want.
      # 
      # Options:
      # 
      # * :as - override the input type (eg force a :string to render as a :password field)
      # * :label - use something other than the method name as the label (or fieldset legend) text
      # * :required - specify if the column is required (true) or not (false)
      # * :hint - provide some text to hint or help the user provide the correct information for a field
      # 
      # Input Types:
      # 
      # Most inputs map directly to one of ActiveRecord's column types by default (eg string_input), 
      # but there are a few special cases and some simplification (:integer, :float and :decimal 
      # columns) all map to a single numeric_input, for example). 
      # 
      # * :select (<select> menu for objects in a belongs_to association) - default for fields ending in '_id'
      # * :radio (a set of radio buttons for objects in the parent association) - alternative for fields ending in '_id'
      # * :password (a password input field) - default for :string column types with 'password' in the method name
      # * :text (a textarea) - default for :text column types
      # * :date (a date select) - default for :date column types
      # * :datetime (a date and time select) - default for :datetime and :timestamp column types
      # * :time (a time select) - default for :time column types
      # * :boolean (a checkbox) - default for :boolean column types
      # * :string (a text field input) - default for :string column types
      # * :numeric (a text field input, like string) - default for :integer, :float and :decimal column types
      # 
      # Example:
      # 
      #   <% semantic_form_for @employee do |form| %>
      #     <% form.input_field_set do -%>
      #       <%= form.input :name, :label => "Full Name"%>
      #       <%= form.input :manager_id, :as => :radio %>
      #       <%= form.input :hired_at, :as => :date, :label => "Date Hired" %>
      #       <%= form.input :phone, :required => false, :hint => "Eg: +1 555 1234" %>
      #     <% end %>
      #   <% end %>
      def input(method, options = {})
        raise "@#{@object_name} doesn't respond to the method #{method}" unless @template.instance_eval("@#{@object_name}").respond_to?(method) # TODO
        
        options[:required] = @@all_fields_required_by_default if options[:required].nil?
        options[:label] ||= method.to_s.humanize
        options[:as] ||= default_input_type(@object_name, method)
        
        input_method = "#{options[:as]}_input"
        raise("Cannot guess an input type for '#{method}' - please set :as option") unless respond_to?(input_method) 
        content = ''
        content += send(input_method, method, options) # eg string_input or select_input
        content += inline_errors(method, options)
        content += inline_hints(method, options)
        
        return @template.content_tag(:li, content, list_item_html_attributes(method, options))
      end
      
      # Creates a fieldset and ol tag wrapping for form inputs as list items.  Example:
      # 
      #   <% form_for @user do |form| %>
      #     <% form.input_field_set do %>
      #       <li>form input 1</li>
      #       <li>form input 2</li>
      #     <% end %>
      #   <% end %>
      #
      # Output:
      #   <form ...>
      #     <fieldset class="inputs">
      #       <ol>
      #         <li>form input 1</li>
      #         <li>form input 2</li>
      #       </ol>
      #     </fieldset>
      #   </form>
      # 
      # HTML attributes for the fieldset can be passed in as a hash before the block, with the class
      # set to "inputs" by default.  Example:
      #   <% input_field_set :id => "main-inputs" do %>
      #     ...
      #   <% end %>
      def input_field_set(field_set_html_options = {}, &block)
        field_set_html_options[:class] ||= "inputs"
        field_set_and_list_wrapping(field_set_html_options, &block)
      end
      
      # Creates a fieldset and ol tag wrapping for form buttons / actions as list items.  
      # See input_field_set documentation for a full example.  The fieldset's default class attriute
      # is set to "buttons".
      def button_field_set(field_set_html_options = {}, &block)
        field_set_html_options[:class] ||= "buttons"
        field_set_and_list_wrapping(field_set_html_options, &block)
      end
      
      # TODO: Not really implemented yet.
      def commit_button(value = "submit", options = {})
        @template.submit_tag(value, options) 
      end
      
      # TODO: Not implemented yet, just use Rails' standard error stuff for now.
      def error_messages
        raise "not implemented yet" 
      end
      
      
      protected
      
      
      #   <label for="vehicle_owner_id">Owner</label>
      #   <select id="vehicle_owner_id" name="vehicle[owner_id]">
      #     <option value="1">Justin French</option>
      #     <option value="2">Jane Doe</option>
      #   </select>
      def select_input(method, options)
        parent_class = method.to_s.sub(/_id$/,'').camelize.constantize
        choices = parent_class.find(:all).map {|o| [o.name, o.id]} # TODO
        input_label(method, options) + @template.select(@object_name, method, choices, options)
      end
      
      
      # Outputs a fieldset containign a legend for the label text, and an ordered list (ol) of list
      # items, one for each possible choice in the belongs_to association.  Each li contains a 
      # label and a radio input.  Example:
      # 
      #   <fieldset>
      #     <legend><span>Owner</span></legend>
      #     <ol>
      #       <li>
      #         <label for="vehicle_owner_id_1"><input id="vehicle_owner_id_1" name="vehicle[owner_id]" type="radio" value="1" /> Justin French</label>
      #       </li>
      #       <li>
      #         <label for="vehicle_owner_id_2"><input id="vehicle_owner_id_2" name="vehicle[owner_id]" type="radio" value="2" /> Jane Doe</label>
      #       </li>
      #     </ol>
      #   </fieldset>
      # 
      # TODO: need ordering and conditions on the find() for the belongs_to choices, or maybe a finder method override.
      def radio_input(method, options)
        parent_class = method.to_s.sub(/_id$/,'').camelize.constantize
        choices = parent_class.find(:all) # TODO
        
        @template.content_tag(:fieldset, 
          %{<legend><span>#{label_text(method, options)}</span></legend>} + 
          @template.content_tag(:ol, 
            choices.map { |c| 
              @template.content_tag(:li,
                input_label(method, options, "#{@template.radio_button(@object_name, method, c.id)} #{c.name}") # TODO
              )
            }
          )
        )  
      end


      # Outputs a label and a password input, nothing fancy.
      def password_input(method, options)
        input_label(method, options) + @template.password_field(@object_name, method, options)   
      end
      
      
      # Outputs a label and a textarea, nothing fancy.
      def text_input(method, options)
        input_label(method, options) + @template.text_area(@object_name, method, options)   
      end
      
      
      # Outputs a label and a text input, nothing fancy, but it does pick up some attributes like 
      # size and maxlen -- see default_string_options() for the low-down.
      def string_input(method, options)
        input_label(method, options) + 
        @template.text_field(@object_name, method, options.reverse_merge(default_string_options(method)))
      end
      
      
      # Same as string_input for now
      def numeric_input
        input_label(method, options) + 
        @template.text_field(@object_name, method, options.reverse_merge(default_string_options(method)))
      end
       
            
      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the date (year, month, day).  Each li contains a label
      # (eg "Year") and a select box.  See date_or_datetime_input for a more detailed output example.
      # 
      # Some of Rails' options for select_date are supported, but not everything yet.
      def date_input(method, options)
        date_or_datetime_input(method, options.merge(:discard_hour => true))
      end
      
      
      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the date (year, month, day, hour, min, sec).  Each li 
      # contains a label (eg "Year") and a select box.  See date_or_datetime_input for a more 
      # detailed output example.
      # 
      # Some of Rails' options for select_date are supported, but not everything yet.
      def datetime_input(method, options)
        date_or_datetime_input(method, options)
      end
      
      
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
      # TODO: This is an absolute abomination, but so is the official Rails select_date().  Mainly
      # missing the ability to re-order the inputs.
      def date_or_datetime_input(method, options)
        position = { :year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => 6 }
        inputs = [:year, :month, :day, :hour, :minute, :second]
                
        list_items_capture = ""
        inputs.each do |input|
          if options["discard_#{input}".intern]
            break
          else
            list_items_capture << @template.content_tag(:li, 
              @template.content_tag(:label, input.to_s.humanize, :for => "#{@object_name}_#{method}_#{position[input]}i") + 
              @template.send("select_#{input}".intern, @template.instance_eval("@#{@object_name}").send(method), options.merge(:prefix => @object_name, :field_name => "#{method}(#{position[input]}i)"))
            )
          end
        end
        
        @template.content_tag(:fieldset, 
          %{<legend><span>#{label_text(method, options)}</span></legend>} + 
          @template.content_tag(:ol, list_items_capture)
        )
      end
      
      
      # TODO - needs some work eh?
      def time_input(method, options)
        input_label(method, options) + @template.time_select(@object_name, method, options)   
      end
      
       
      # Outputs a label containing a checkbox and the label text.
      # 
      # TODO - what about a yes/no boolean?
      def boolean_input(method, options)
        input_label(method, options, 
          @template.check_box(@object_name, method, options) + 
          label_text(method, options)
        )
      end
    
      def inline_errors(method, options)  #:nodoc:
        errors = @template.instance_eval("@#{@object_name}").errors.on(method).to_a
        errors.empty? ? '' : @template.content_tag(:p, errors.to_sentence, :class => 'inline-errors')
      end
      
      def inline_hints(method, options) #:nodoc:
        options[:hint].blank? ? '' : @template.content_tag(:p, options[:hint], :class => 'inline-hints')
      end
      
      def label_text(method, options) #:nodoc:
        [ options[:label], required_or_optional_string(options[:required]) ].join()
      end
      
      def input_label(method, options, text = nil) #:nodoc:
        text ||= label_text(method, options)
        @template.label(@object_name, method, text)
      end
      
      def required_or_optional_string(required) #:nodoc:
        required ? @@required_string : @@optional_string
      end
      
      def field_set_and_list_wrapping(field_set_html_options, &block) #:nodoc:
        @template.concat(
          @template.content_tag(:fieldset, 
            @template.content_tag(:ol, @template.capture(&block)),
            field_set_html_options
          ), 
          block.binding
        )
      end
      
      def default_input_type(object_name, method) #:nodoc:
        if type = @template.instance_eval("@#{object_name}").send("column_for_attribute", method).type
          
          # handle the special cases where the column type doesn't map to an input method
          return :select if type == :integer && method.to_s =~ /_id$/
          return :password if type == :string && method =~ /password/
          return :datetime if type == :timestamp
          return :numeric if [:integer, :float, :decimal].include?(type)
          
          # otherwise assume the input name will be the same as the column type (eg string_input)
          return type
        end
      end
      
      def default_string_options(method) #:nodoc:
        column = @template.instance_eval("@#{@object_name}").class.columns_hash[method.to_s]
        if column.nil? || column.limit.nil?
          { :size => DEFAULT_TEXT_FIELD_SIZE }
        else
          { :maxlen => column.limit, :size => [column.limit, DEFAULT_TEXT_FIELD_SIZE].min }
        end       
      end
      
      def list_item_html_attributes(method, options) #:nodoc:
        classes = [options[:as].to_s]
        classes << (options[:required] ? 'required' : 'optional')
        classes << 'error' if @template.instance_eval("@#{@object_name}").errors.on(method)
        return { :id => "#{@object_name}_#{method}_input", :class => classes.join(" ") } 
      end
      
    end
    
  end
end
