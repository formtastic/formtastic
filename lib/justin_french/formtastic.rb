module JustinFrench #:nodoc:
  module Formtastic #:nodoc:
    
    # Wrappers around form_for (etc) with :builder => SemanticFormBuilder.
    #
    # * semantic_form_for(@post)
    # * semantic_fields_for(@post)
    # * semantic_form_remote_for(@post)
    # * semantic_remote_form_for(@post)
    # 
    # Each of which are the equivalent of:
    #
    # * form_for(@post, :builder => JustinFrench::Formtastic::SemanticFormBuilder))
    # * fields_for(@post, :builder => JustinFrench::Formtastic::SemanticFormBuilder))
    # * form_remote_for(@post, :builder => JustinFrench::Formtastic::SemanticFormBuilder))
    # * remote_form_for(@post, :builder => JustinFrench::Formtastic::SemanticFormBuilder))
    # 
    # Example Usage:
    #   
    #   <% semantic_form_for @post do |f| %>
    #     <%= f.input :title %>
    #     <%= f.input :body %>
    #   <% end %>
    #
    # The above examples use a resource-oriented style of form_for() helper where only the @post
    # object is given as an argument, but the generic style is also supported if you really want it, 
    # as is forms with inline objects (Post.new) rather than objects with instance variables (@post):
    #
    #   <% semantic_form_for :post, @post, :url => posts_path do |f| %>
    #     ...
    #   <% end %>
    #
    #   <% semantic_form_for :post, Post.new, :url => posts_path do |f| %>
    #     ...
    #   <% end %>
    #
    # The shorter, resource-oriented style is most definitely preferred, and has recieved the most
    # testing to date.
    #
    # Please note: Although it's possible to call Rails' built-in form_for() helper without an 
    # object, all semantic forms *must* have an object (either Post.new or @post), as Formtastic 
    # has too many dependencies on an ActiveRecord object being present.
    module SemanticFormHelper
      [:form_for, :fields_for, :form_remote_for, :remote_form_for].each do |meth|
        src = <<-END_SRC   
          def semantic_#{meth}(record_or_name_or_array, *args, &proc)
            options = args.extract_options!            
            #{meth}(record_or_name_or_array, *(args << options.merge(:builder => JustinFrench::Formtastic::SemanticFormBuilder, :html => { :class => "formtastic new_" + record_or_name_or_array.class.to_s.underscore })), &proc)
          end
        END_SRC
        module_eval src, __FILE__, __LINE__
      end
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
      # columns all map to a single numeric_input, for example). 
      # 
      # * :select (a select menu for belongs_to associations) - default for columns ending in '_id'
      # * :radio (a set of radio inputs for belongs_to associations) - alternative for columns ending in '_id'
      # * :password (a password input) - default for :string column types with 'password' in the method name
      # * :text (a textarea) - default for :text column types
      # * :date (a date select) - default for :date column types
      # * :datetime (a date and time select) - default for :datetime and :timestamp column types
      # * :time (a time select) - default for :time column types
      # * :boolean (a checkbox) - default for :boolean column types
      # * :boolean_select (a yes/no select box)
      # * :string (a text field) - default for :string column types
      # * :numeric (a text field, like string) - default for :integer, :float and :decimal column types
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
        raise NoMethodError unless @object.respond_to?(method)
        
        options[:required] = method_required?(method, options[:required])
        options[:label] ||= method.to_s.humanize
        options[:as] ||= default_input_type(@object, method)
        input_method = "#{options[:as]}_input"
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
      #
      # One special option exists (:name), which is passed along to a legend tag within the 
      # fieldset (otherwise a legend is not generated):
      #
      #   <% input_field_set :name => "Advanced Options" do %>...<% end %>
      def input_field_set(field_set_html_options = {}, &block)
        field_set_html_options[:class] ||= "inputs"
        field_set_and_list_wrapping(field_set_html_options, &block)
      end
      
      # Creates a fieldset and ol tag wrapping for form buttons / actions as list items.  
      # See input_field_set documentation for a full example.  The fieldset's default class attriute
      # is set to "buttons".
      #
      # See input_field_set for html attriutes and special options.
      def button_field_set(field_set_html_options = {}, &block)
        field_set_html_options[:class] ||= "buttons"
        field_set_and_list_wrapping(field_set_html_options, &block)
      end
      
      # Creates a submit input tag with the value "Save [model name]" (for existing records) or 
      # "Create [model name]" (for new records) by default:
      # 
      #   <%= form.commit_button %> => <input name="commit" type="submit" value="Save Post" />
      # 
      # The value of the button text can be overridden:
      #
      #  <%= form.commit_button "Go" %> => <input name="commit" type="submit" value="Go" />
      def commit_button(value = save_or_create_commit_button_text, options = {})
        @template.submit_tag(value) 
      end
      
      protected
      
      def save_or_create_commit_button_text #:nodoc:
        prefix = @object.new_record? ? "Create" : "Save"
        "#{prefix} #{@object_name.humanize}"
      end
      
      # Determins if the attribute (eg :title) should be considered required or not.
      #
      # * if the :required option was provided in the options hash, the true/false value will be 
      #   returned immediately, allowing the view to override any guesswork that follows:
      # * if the :required option isn't provided in the options hash, and the ValidationReflection 
      #   plugin is installed (http://github.com/redinger/validation_reflection), true is returned
      #   if the validates_presence_of macro has been used in the class for this attribute, or false
      #   otherwise.
      # * if the :required option isn't provided, and the plugin isn't available, the value of the
      #   configuration option @@all_fields_required_by_default is used.
      def method_required?(attribute, required_option) #:nodoc:
        return required_option unless required_option.nil?
        
        if @object.class.method_defined?(:reflect_on_all_validations)
          attribute_sym = attribute.to_s.sub(/_id$/, '').to_sym
          @object.class.reflect_on_all_validations.any? do |validation|
            validation.macro == :validates_presence_of && validation.name == attribute_sym
          end
        else
          @@all_fields_required_by_default
        end
      end
      
      # Outputs a label and a select box containing options from the parent (belongs_to) association.
      #
      #   <label for="vehicle_owner_id">Owner</label>
      #   <select id="vehicle_owner_id" name="vehicle[owner_id]">
      #     <option value="1">Justin French</option>
      #     <option value="2">Jane Doe</option>
      #   </select>
      #
      # Note: This input calls #to_label on each record in the parent association, so in the example
      # where a Post belongs_to an Author, you need to define an instance method to_label on Post, 
      # which will be used as the text for the each option in the select.  You can specify an 
      # alternate method with the :label_method option:
      #
      #   f.input :author_id, :as => :select, :label_method => :full_name
      #
      # TODO: need ordering and conditions on the find() for the belongs_to choices, or maybe a 
      # finder method override.
      def select_input(method, options)
        options[:label_method] ||= :to_label

        parent_class = method.to_s.sub(/_id$/,'').camelize.constantize
        choices = parent_class.find(:all).map {|o| [o.send(options[:label_method]), o.id]}
        
        input_label(method, options) + @template.select(@object_name, method, choices)
      end
      
      
      # Outputs a fieldset containing a legend for the label text, and an ordered list (ol) of list
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
      # Note: This input calls #to_label on each record in the parent association, so in the example
      # where a Post belongs_to an Author, you need to define an instance method to_label on Post, 
      # which will be used as the text for the labels next to each radio button. You can specify an 
      # alternate method with the :label_method option:
      #
      #   f.input :author_id, :as => :radio, :label_method => :full_name
      #
      # TODO: need ordering and conditions on the find() for the belongs_to choices, or maybe a 
      # finder method override.
      def radio_input(method, options)
        options[:label_method] ||= :to_label
                
        parent_class = method.to_s.sub(/_id$/,'').camelize.constantize
        choices = parent_class.find(:all) # TODO
        
        @template.content_tag(:fieldset, 
          %{<legend><span>#{label_text(method, options)}</span></legend>} + 
          @template.content_tag(:ol, 
            choices.map { |c| 
              @template.content_tag(:li, 
                @template.content_tag(:label, 
                  "#{@template.radio_button(@object_name, method, c.id)} #{c.send(options[:label_method])}", 
                  :for => "#{@object_name}_#{method}_#{c.id}"
                )
              )
            }
          )
        )
      end


      # Outputs a label and a password input, nothing fancy.
      def password_input(method, options)
        input_label(method, options) + 
        @template.password_field(@object_name, method, default_string_options(method))   
      end
      
      
      # Outputs a label and a textarea, nothing fancy.
      def text_input(method, options)
        input_label(method, options) + @template.text_area(@object_name, method)   
      end
      
      
      # Outputs a label and a text input, nothing fancy, but it does pick up some attributes like 
      # size and maxlength -- see default_string_options() for the low-down.
      def string_input(method, options)
        input_label(method, options) + 
        @template.text_field(@object_name, method, default_string_options(method))
      end
      
      
      # Same as string_input for now
      def numeric_input(method, options)
        input_label(method, options) + 
        @template.text_field(@object_name, method, default_string_options(method))
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
      
      
      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the time (hour, minute, second).  Each li contains a label
      # (eg "Hour") and a select box.  See date_or_datetime_input for a more detailed output example.
      # 
      # Some of Rails' options for select_time are supported, but not everything yet.
      def time_input(method, options)
        date_or_datetime_input(method, options.merge(:discard_year => true, :discard_month => true, :discard_day => true))
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
      # This is an absolute abomination, but so is the official Rails select_date().  Mainly
      # missing the ability to re-order the inputs, but maybe that's fine!
      def date_or_datetime_input(method, options)
        position = { :year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => 6 }
        inputs = [:year, :month, :day]
        time_inputs = [:hour, :minute]
        time_inputs << [:second] if options[:include_seconds]
                
        list_items_capture = ""
        (inputs + time_inputs).each do |input|
          if options["discard_#{input}".intern]
            break if time_inputs.include?(input)
            list_items_capture << @template.hidden_field_tag("#{@object_name}[#{method}(#{position[input]}i)]", @object.send(method), :id => "#{@object_name}_#{method}_#{position[input]}i")
          else
            list_items_capture << @template.content_tag(:li, 
              @template.content_tag(:label, input.to_s.humanize, :for => "#{@object_name}_#{method}_#{position[input]}i") + 
              @template.send("select_#{input}".intern, @object.send(method), :prefix => @object_name, :field_name => "#{method}(#{position[input]}i)")
            )
          end
        end
        
        @template.content_tag(:fieldset, 
          %{<legend><span>#{label_text(method, options)}</span></legend>} + 
          @template.content_tag(:ol, list_items_capture)
        )
      end
            
      # Outputs a label containing a checkbox and the label text.  The label defaults to the column
      # name (method name) and can be altered with the :label option.
      def boolean_input(method, options)
        input_label(method, options, 
          @template.check_box(@object_name, method) + 
          label_text(method, options)
        )
      end
      
      # Outputs a label and select box containing two options for "true" and "false". The visible
      # text defaults to "Yes" and "No" respectively, but can be altered with the :true and :false
      # options.  The label text to the column name (method name), but can be altered with the 
      # :label option. Example:
      #
      #  f.input :awesome, :as => :boolean_select, :true => "Yeah!", :false => "Nah!", :label => "Make this sucker public?"
      #
      # Returns something like:
      # 
      #  <li class="boolean_select required" id="post_public_input">
      #    <label for="post_public">
      #      Make this sucker public?<abbr title="required">*</abbr>
      #    </label>
      #    <select id="post_public" name="post[public]">
      #      <option value="1">Yeah!</option>
      #      <option value="0">Nah!</option>
      #    </select>
      #  </li>
      #
      # TODO: Doesn't handle :include_blank => true, but then again, neither do most of the inputs.
      def boolean_select_input(method, options)
        options[:true] ||= "Yes"
        options[:false] ||= "No"
        
        choices = [ [options[:true],true], [options[:false],false] ]
        input_label(method, options) + @template.select(@object_name, method, choices)
      end
      
      # Outputs a fieldset containing two radio buttons (with labels) for "true" and "false". The 
      # visible label text for each option defaults to "Yes" and "No" respectively, but can be 
      # altered with the :true and :false options.  The fieldset legend defaults to the column name
      # (method name), but can be altered with the :label option.  Example:
      #
      #  f.input :awesome, :as => :boolean_radio, :true => "Yeah!", :false => "Nah!", :label => "Awesome?"
      #
      # Returns something like:
      #
      #  <li class="boolean_radio required" id="post_public_input">
      #    <fieldset><legend><span>make this sucker public?<abbr title="required">*</abbr></span></legend>
      #      <ol>
      #        <li>
      #          <label for="post_public_true">
      #            <input id="post_public_true" name="post[public]" type="radio" value="true" /> Yeah!
      #          </label>
      #        </li>
      #        <li>
      #          <label for="post_public_false">
      #            <input id="post_public_false" name="post[public]" type="radio" checked="checked" /> Nah!
      #          </label>
      #        </li>
      #      </ol>
      #    </fieldset>
      #  </li>
      def boolean_radio_input(method, options)
        options[:true] ||= "Yes"
        options[:false] ||= "No"

        choices = [ {:label => options[:true], :value => true}, {:label => options[:false], :value => false} ]

        @template.content_tag(:fieldset, 
          %{<legend><span>#{label_text(method, options)}</span></legend>} + 
          @template.content_tag(:ol, 
            choices.map { |c| 
              @template.content_tag(:li,
                @template.label_tag("#{@object_name}_#{method}_#{c[:value]}", 
                  "#{@template.radio_button_tag("#{@object_name}[#{method}]", c[:value].to_s, (@object.send(method) == c[:value]), :id => "#{@object_name}_#{method}_#{c[:value]}")} #{c[:label]}"
                ),
              :class => c[:value].to_s)
            }
          )
        )
      end
      
      def inline_errors(method, options)  #:nodoc:
        errors = @object.errors.on(method).to_a
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
        legend_text = field_set_html_options.delete(:name)
        legend = legend_text.blank? ? "" : @template.content_tag(:legend, @template.content_tag(:span, legend_text))
        
        @template.concat(
          @template.content_tag(:fieldset, 
            legend + @template.content_tag(:ol, @template.capture(&block)),
            field_set_html_options
          )
        )
      end
      
      # For methods that have a database column, take a best guess as to what the inout method
      # should be.  In most cases, it will just return the column type (eg :string), but for special
      # cases it will simplify (like the case of :integer, :float & :decimal to :numeric), or do
      # something different (like :password and :select).
      #
      # If there is no column for the method (eg "virtual columns" with an attr_accessor), an error
      # is raised asking you to specify the :as option for the input.
      def default_input_type(object, method) #:nodoc:
        column = object.send("column_for_attribute", method)
        if column
          # handle the special cases where the column type doesn't map to an input method
          return :select if column.type == :integer && method.to_s =~ /_id$/
          return :datetime if column.type == :timestamp
          return :numeric if [:integer, :float, :decimal].include?(column.type)
          return :password if column.type == :string && method.to_s =~ /password/
          # otherwise assume the input name will be the same as the column type (eg string_input)
          return column.type
        else
          raise("Cannot guess an input type for '#{method}' - please set :as option")
        end          
      end
            
      def default_string_options(method) #:nodoc:
        column = @object.column_for_attribute(method)
        if column.nil? || column.limit.nil?
          { :size => DEFAULT_TEXT_FIELD_SIZE }
        else
          { :maxlength => column.limit, :size => [column.limit, DEFAULT_TEXT_FIELD_SIZE].min }
        end       
      end
      
      def list_item_html_attributes(method, options) #:nodoc:
        classes = [options[:as].to_s]
        classes << (options[:required] ? 'required' : 'optional')
        classes << 'error' if @object.errors.on(method)
        return { :id => "#{@object_name}_#{method}_input", :class => classes.join(" ") } 
      end
      
    end
    
  end
end
