# Override the default ActiveRecordHelper behaviour of wrapping the input.
# This gets taken care of semantically by adding an error class to the LI tag
# containing the input.
module ActionView
  module Helpers
    class InstanceTag
      alias_method :error_wrapping_with_wrapping, :error_wrapping
      def error_wrapping(html_tag, has_error)
        html_tag
      end
    end
  end
end

module Formtastic #:nodoc:

  class SemanticFormBuilder < ActionView::Helpers::FormBuilder

    DEFAULT_TEXT_FIELD_SIZE = 50

    @@all_fields_required_by_default = true
    @@required_string = %{<abbr title="required">*</abbr>}
    @@optional_string = ''
    @@inline_errors = :sentence

    cattr_accessor :all_fields_required_by_default, :required_string, :optional_string, :inline_errors

    attr_accessor :template


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
    #     <% form.inputs do -%>
    #       <%= form.input :name, :label => "Full Name"%>
    #       <%= form.input :manager_id, :as => :radio %>
    #       <%= form.input :hired_at, :as => :date, :label => "Date Hired" %>
    #       <%= form.input :phone, :required => false, :hint => "Eg: +1 555 1234" %>
    #     <% end %>
    #   <% end %>
    def input(method, options = {})
      raise NoMethodError.new("NoMethodError: form object does not respond to \"#{method}\"") unless @object.respond_to?(method)


      options[:required] = method_required?(method, options[:required])
      options[:label] ||= method.to_s.titleize
      options[:as] ||= default_input_type(@object, method)
      input_method = "#{options[:as]}_input"

      html_class = [
        options[:as].to_s,
        (options[:required] ? 'required' : 'optional'),
        (@object.errors.on(method.to_s) ? 'error' : nil)
      ].compact.join(" ")

      html_id = "#{@object_name}_#{method}_input"

      list_item_content = [
        send(input_method, method, options),
        inline_hints(method, options),
        inline_errors(method, options)
      ].compact.join("\n")

      return template.content_tag(:li, list_item_content, { :id => html_id, :class => html_class })
    end

    # Creates an input fieldset and ol tag wrapping for use around a set of inputs.  It can be
    # called either with a block (in which you can do the usual Rails form stuff, HTML, ERB, etc),
    # or with a list of fields.  These two examples are functionally equivalent:
    #
    #   # With a block:
    #   <% semantic_form_for @post do |form| %>
    #     <% form.inputs do %>
    #       <%= form.input :title %>
    #       <%= form.input :body %>
    #     <% end %>
    #   <% end %>
    #
    #   # With a list of fields:
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs :title, :body %>
    #   <% end %>
    #
    #   # Output:
    #   <form ...>
    #     <fieldset class="inputs">
    #       <ol>
    #         <li class="string">...</li>
    #         <li class="text">...</li>
    #       </ol>
    #     </fieldset>
    #   </form>
    #
    # === Quick Forms
    #
    # When called without a block or a field list, an input is rendered for each column in the
    # model's database table, just like Rails' scaffolding.  You'll obviously want more control
    # than this in a production application, but it's a great way to get started, then come back
    # later to customise the form with a field list or a block of inputs.  Example:
    #
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs %>
    #   <% end %>
    #
    # === Options
    #
    # All options (with the exception of :name) are passed down to the fieldset as HTML
    # attributes (id, class, style, etc).  If provided, the :name option is passed into a
    # legend tag inside the fieldset (otherwise a legend is not generated).
    #
    #   # With a block:
    #   <% semantic_form_for @post do |form| %>
    #     <% form.inputs :name => "Create a new post", :style => "border:1px;" do %>
    #       ...
    #     <% end %>
    #   <% end %>
    #
    #   # With a list (the options must come after the field list):
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs :title, :body, :name => "Create a new post", :style => "border:1px;" %>
    #   <% end %>
    #
    # === It's basically a fieldset!
    #
    # Instead of hard-coding fieldsets & legends into your form to logically group related fields,
    # use inputs:
    #
    #   <% semantic_form_for @post do |f| %>
    #     <% f.inputs do %>
    #       <%= f.input :title %>
    #       <%= f.input :body %>
    #     <% end %>
    #     <% f.inputs :name => "Advanced", :id => "advanced" do %>
    #       <%= f.input :created_at %>
    #       <%= f.input :user_id, :label => "Author" %>
    #     <% end %>
    #   <% end %>
    #
    #   # Output:
    #   <form ...>
    #     <fieldset class="inputs">
    #       <ol>
    #         <li class="string">...</li>
    #         <li class="text">...</li>
    #       </ol>
    #     </fieldset>
    #     <fieldset class="inputs" id="advanced">
    #       <legend><span>Advanced</span></legend>
    #       <ol>
    #         <li class="datetime">...</li>
    #         <li class="select">...</li>
    #       </ol>
    #     </fieldset>
    #   </form>
    def inputs(*args, &block)
      if block_given?
        html_options = args.first || {}
        html_options[:class] ||= "inputs"
        field_set_and_list_wrapping(html_options, &block)
      else
        html_options = args.last.is_a?(Hash) ? args.pop : {}
        html_options[:class] ||= "inputs"
        args = @object.class.column_names if args.empty?
        contents = args.map { |method| input(method.to_sym) }
        field_set_and_list_wrapping(html_options, contents)
      end
    end
    alias_method :input_field_set, :inputs

    # Creates a fieldset and ol tag wrapping for form buttons / actions as list items.
    # See inputs documentation for a full example.  The fieldset's default class attriute
    # is set to "buttons".
    #
    # See inputs for html attributes and special options.
    def buttons(*args, &block)
      if block_given?
        html_options = args.first || {}
        html_options[:class] ||= "buttons"
        field_set_and_list_wrapping(html_options, &block)
      else
        html_options = args.last.is_a?(Hash) ? args.pop : {}
        html_options[:class] ||= "buttons"
        args = [:commit] if args.empty?
        contents = args.map { |button_name| send(:"#{button_name}_button") }
        field_set_and_list_wrapping(html_options, contents)
      end
    end
    alias_method :button_field_set, :buttons

    # Creates a submit input tag with the value "Save [model name]" (for existing records) or
    # "Create [model name]" (for new records) by default:
    #
    #   <%= form.commit_button %> => <input name="commit" type="submit" value="Save Post" />
    #
    # The value of the button text can be overridden:
    #
    #  <%= form.commit_button "Go" %> => <input name="commit" type="submit" value="Go" />
    def commit_button(value = save_or_create_commit_button_text, options = {})
      template.content_tag(:li, template.submit_tag(value), :class => "commit")
    end


    # A thin wrapper around #fields_for to set :builder => Formtastic::SemanticFormBuilder
    # for nesting forms:
    #
    #   # Example:
    #   <% semantic_form_for @post do |post| %>
    #     <% post.semantic_fields_for :author do |author| %>
    #       <% author.inputs :name %>
    #     <% end %>
    #   <% end %>
    #
    #   # Output:
    #   <form ...>
    #     <fieldset class="inputs">
    #       <ol>
    #         <li class="string"><input type='text' name='post[author][name]' id='post_author_name' /></li>
    #       </ol>
    #     </fieldset>
    #   </form>
    def semantic_fields_for(record_or_name_or_array, *args, &block)
      opts = args.extract_options!
      opts.merge!(:builder => Formtastic::SemanticFormBuilder)
      args.push(opts)
      fields_for(record_or_name_or_array, *args, &block)
    end

    protected

    # Ensure :object => @object is set before sending the options down to the Rails layer.
    # Also remove any Formtastic-specific options
    def set_options(options)
      opts = options.dup
      [:value_method, :label_method, :collection, :required, :label, :as, :hint].each do |key|
        opts.delete(key)
      end
      opts.merge(:object => @object)
    end

    def save_or_create_commit_button_text #:nodoc:
      prefix = @object.new_record? ? "Create" : "Save"
      "#{prefix} #{@object_name.to_s.humanize}"
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
    # Example:
    #
    #   f.input :author_id, :as => :select
    #
    #   <label for="book_author_id">Author</label>
    #   <select id="book_author_id" name="book[author_id]">
    #     <option value="1">Justin French</option>
    #     <option value="2">Jane Doe</option>
    #   </select>
    #
    # You can customize the options available in the select by passing in a collection (Array) of
    # ActiveRecord objects through the :collection option.  If not provided, the choices are found
    # by inferring the parent's class name from the method name and simply calling find(:all) on
    # it (VehicleOwner.find(:all) in the example above).
    #
    # Examples:
    #
    #   f.input :author_id, :as => :select, :collection => @authors
    #   f.input :author_id, :as => :select, :collection => Author.find(:all)
    #   f.input :author_id, :as => :select, :collection => [@justin, @kate]
    #
    # Note: This input calls #to_label on each record in the parent association, so in the example
    # where a Post belongs_to an Author, you need to define an instance method to_label on Post,
    # which will be used as the text for the each option in the select.  You can specify an
    # alternate method with the :label_method option:
    #
    # You can customize the text label inside each option tag, by naming the correct method
    # (:full_name, :display_name, :account_number, etc) to call on each object in the collection
    # by passing in the :label_method option.  By default the :label_method is :to_label.
    #
    # Examples:
    #
    #   f.input :author_id, :as => :select, :label_method => :full_name
    #   f.input :author_id, :as => :select, :label_method => :display_name
    #   f.input :author_id, :as => :select, :label_method => :to_s
    #   f.input :author_id, :as => :select, :label_method => :label
    #
    # You can also customize the value inside each option tag, by passing in the :value_method option.
    # Usage is the same as the :label_method option
    #
    # Examples:
    #
    #   f.input :author_id, :as => :select, :value_method => :full_name
    #   f.input :author_id, :as => :select, :value_method => :display_name
    #   f.input :author_id, :as => :select, :value_method => :to_s
    #   f.input :author_id, :as => :select, :value_method => :value
    def select_input(method, options)
      options[:collection] ||= find_parent_objects_for_column(method)
      options[:label_method] ||= options[:collection].first.respond_to?(:to_label) ? :to_label : :to_s
      options[:value_method] ||= :id

      choices = options[:collection].map { |o| [o.send(options[:label_method]), o.send(options[:value_method])] }
      input_label(method, options) + template.select(@object_name, method, choices, set_options(options))
    end


    # Outputs a fieldset containing a legend for the label text, and an ordered list (ol) of list
    # items, one for each possible choice in the belongs_to association.  Each li contains a
    # label and a radio input.
    #
    # Example:
    #
    #   f.input :author_id, :as => :radio
    #
    # Output:
    #
    #   <fieldset>
    #     <legend><span>Author</span></legend>
    #     <ol>
    #       <li>
    #         <label for="book_author_id_1"><input id="book_author_id_1" name="book[author_id]" type="radio" value="1" /> Justin French</label>
    #       </li>
    #       <li>
    #         <label for="book_author_id_2"><input id="book_author_id_2" name="book[owner_id]" type="radio" value="2" /> Kate French</label>
    #       </li>
    #     </ol>
    #   </fieldset>
    #
    # You can customize the options available in the set by passing in a collection (Array) of
    # ActiveRecord objects through the :collection option.  If not provided, the choices are found
    # by inferring the parent's class name from the method name and simply calling find(:all) on
    # it (VehicleOwner.find(:all) in the example above).
    #
    # Examples:
    #
    #   f.input :author_id, :as => :radio, :collection => @authors
    #   f.input :author_id, :as => :radio, :collection => Author.find(:all)
    #   f.input :author_id, :as => :radio, :collection => [@justin, @kate]
    #
    # You can also customize the text label inside each option tag, by naming the correct method
    # (:full_name, :display_name, :account_number, etc) to call on each object in the collection
    # by passing in the :label_method option.  By default the :label_method is :to_label.
    #
    # Examples:
    #
    #   f.input :author_id, :as => :radio, :label_method => :full_name
    #   f.input :author_id, :as => :radio, :label_method => :display_name
    #   f.input :author_id, :as => :radio, :label_method => :to_s
    #   f.input :author_id, :as => :radio, :label_method => :label
    def radio_input(method, options)
      options[:collection] ||= find_parent_objects_for_column(method)
      options[:label_method] ||= options[:collection].first.respond_to?(:to_label) ? :to_label : :to_s

      template.content_tag(:fieldset,
        %{<legend><span>#{label_text(method, options)}</span></legend>} +
        template.content_tag(:ol,
          options[:collection].map { |c|
            template.content_tag(:li,
              template.content_tag(:label,
                "#{template.radio_button(@object_name, method, c.id, set_options(options))} #{c.send(options[:label_method])}",
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
      template.password_field(@object_name, method, default_string_options(method))
    end


    # Outputs a label and a textarea, nothing fancy.
    def text_input(method, options)
      input_label(method, options) + template.text_area(@object_name, method, set_options(options))
    end


    # Outputs a label and a text input, nothing fancy, but it does pick up some attributes like
    # size and maxlength -- see default_string_options() for the low-down.
    def string_input(method, options)
      input_label(method, options) +
      template.text_field(@object_name, method, default_string_options(method))
    end


    # Same as string_input for now
    def numeric_input(method, options)
      input_label(method, options) +
      template.text_field(@object_name, method, default_string_options(method))
    end

    # Outputs label and file field
    def file_input(method, options)
      input_label(method, options) +
      template.file_field(@object_name, method, set_options(options))
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
          list_items_capture << template.hidden_field_tag("#{@object_name}[#{method}(#{position[input]}i)]", @object.send(method), :id => "#{@object_name}_#{method}_#{position[input]}i")
        else
          opts = set_options(options).merge({:prefix => @object_name, :field_name => "#{method}(#{position[input]}i)", :include_blank => options[:include_blank]})
          list_items_capture << template.content_tag(:li,
            template.content_tag(:label, input.to_s.humanize, :for => "#{@object_name}_#{method}_#{position[input]}i") +
            template.send("select_#{input}".intern, @object.send(method), opts)
          )
        end
      end

      template.content_tag(:fieldset,
        %{<legend><span>#{label_text(method, options)}</span></legend>} +
        template.content_tag(:ol, list_items_capture)
      )
    end

    # Outputs a label containing a checkbox and the label text.  The label defaults to the column
    # name (method name) and can be altered with the :label option.
    def boolean_input(method, options)
      input_label(method, options,
        template.check_box(@object_name, method, set_options(options)) +
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
      input_label(method, options) + template.select(@object_name, method, choices, set_options(options))
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

      template.content_tag(:fieldset,
        %{<legend><span>#{label_text(method, options)}</span></legend>} +
        template.content_tag(:ol,
          choices.map { |c|
            template.content_tag(:li,
              template.label_tag("#{@object_name}_#{method}_#{c[:value]}",
                "#{template.radio_button_tag("#{@object_name}[#{method}]", c[:value].to_s, (@object.send(method) == c[:value]), :id => "#{@object_name}_#{method}_#{c[:value]}")} #{c[:label]}"
              ),
            :class => c[:value].to_s)
          }
        )
      )
    end

    def inline_errors(method, options)  #:nodoc:
      errors = @object.errors.on(method.to_s).to_a
      unless errors.empty?
        send("error_#{@@inline_errors}", errors) if [:sentence, :list].include?(@@inline_errors)
      end
    end

    def error_sentence(errors) #:nodoc:
      template.content_tag(:p, errors.to_sentence, :class => 'inline-errors')
    end

    def error_list(errors) #:nodoc:
      list_elements = []
      errors.each do |error|
        list_elements <<  template.content_tag(:li, error)
      end
      template.content_tag(:ul, list_elements.join("\n"), :class => 'errors')
    end

    def inline_hints(method, options) #:nodoc:
      options[:hint].blank? ? '' : template.content_tag(:p, options[:hint], :class => 'inline-hints')
    end

    def label_text(method, options) #:nodoc:
      [ options[:label], required_or_optional_string(options[:required]) ].join()
    end

    def input_label(method, options, text = nil) #:nodoc:
      text ||= label_text(method, options)
      template.label(@object_name, method, text)
    end

    def required_or_optional_string(required) #:nodoc:
      required ? @@required_string : @@optional_string
    end

    def field_set_and_list_wrapping(field_set_html_options, contents = '', &block) #:nodoc:
      legend_text = field_set_html_options.delete(:name)
      legend = legend_text.blank? ? "" : template.content_tag(:legend, template.content_tag(:span, legend_text))
      if block_given?
        contents = template.capture(&block)
        template.concat(
          template.content_tag(:fieldset,
            legend + template.content_tag(:ol, contents),
            field_set_html_options
          )
        )
      else
        template.content_tag(:fieldset,
          legend + template.content_tag(:ol, contents),
          field_set_html_options
        )
      end

    end

    # For methods that have a database column, take a best guess as to what the inout method
    # should be.  In most cases, it will just return the column type (eg :string), but for special
    # cases it will simplify (like the case of :integer, :float & :decimal to :numeric), or do
    # something different (like :password and :select).
    #
    # If there is no column for the method (eg "virtual columns" with an attr_accessor), the
    # default is a :string, a similar behaviour to Rails' scaffolding.
    def default_input_type(object, method) #:nodoc:
      # rescue if object does not respond to "column_for_attribute" method
      begin
        column = object.send("column_for_attribute", method)
      rescue NoMethodError
        column = nil
      end
      if column
        # handle the special cases where the column type doesn't map to an input method
        return :select if column.type == :integer && method.to_s =~ /_id$/
        return :datetime if column.type == :timestamp
        return :numeric if [:integer, :float, :decimal].include?(column.type)
        return :password if column.type == :string && method.to_s =~ /password/
        # otherwise assume the input name will be the same as the column type (eg string_input)
        return column.type
      else
        return :password if method.to_s =~ /password/
        return :string
      end
    end

    # Used by belongs_to inputs (select, radio) to get a default collection from the parent object
    # by determining the classname from the method/column name (section_id => Section) and doing a
    # simple find(:all).
    def find_parent_objects_for_column(column)
      parent_class = column.to_s.sub(/_id$/,'').camelize.constantize
      parent_class.find(:all)
    end

    def default_string_options(method) #:nodoc:
      # Use rescue to set column if @object does not have a column_for_attribute method
      # (eg if @object is not an ActiveRecord object)
      begin
        column = @object.column_for_attribute(method)
      rescue NoMethodError
        column = nil
      end
      opts = if column.nil? || column.limit.nil?
        { :size => DEFAULT_TEXT_FIELD_SIZE }
      else
        { :maxlength => column.limit, :size => [column.limit, DEFAULT_TEXT_FIELD_SIZE].min }
      end
      set_options(opts)
    end

  end

  # Wrappers around form_for (etc) with :builder => SemanticFormBuilder.
  #
  # * semantic_form_for(@post)
  # * semantic_fields_for(@post)
  # * semantic_form_remote_for(@post)
  # * semantic_remote_form_for(@post)
  #
  # Each of which are the equivalent of:
  #
  # * form_for(@post, :builder => Formtastic::SemanticFormBuilder))
  # * fields_for(@post, :builder => Formtastic::SemanticFormBuilder))
  # * form_remote_for(@post, :builder => Formtastic::SemanticFormBuilder))
  # * remote_form_for(@post, :builder => Formtastic::SemanticFormBuilder))
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
        @@builder = Formtastic::SemanticFormBuilder

        # cattr_accessor :builder
        def self.builder=(val)
          @@builder = val
        end

        def semantic_#{meth}(record_or_name_or_array, *args, &proc)
          options = args.extract_options!
          options[:builder] = @@builder
          options[:html] ||= {}

          class_names = options[:html][:class] ? options[:html][:class].split(" ") : []
          class_names << "formtastic"
          class_names << case record_or_name_or_array
            when String, Symbol then record_or_name_or_array.to_s               # :post => "post"
            when Array then record_or_name_or_array.last.class.to_s.underscore  # [@post, @comment] # => "comment"
            else record_or_name_or_array.class.to_s.underscore                  # @post => "post"
          end
          options[:html][:class] = class_names.join(" ")

          #{meth}(record_or_name_or_array, *(args << options), &proc)
        end
      END_SRC
      module_eval src, __FILE__, __LINE__
    end
  end
end
