# Override the default ActiveRecordHelper behaviour of wrapping the input.
# This gets taken care of semantically by adding an error class to the LI tag
# containing the input.
ActionView::Base.field_error_proc = proc do |html_tag, instance_tag|
  html_tag
end

module Formtastic #:nodoc:

  class SemanticFormBuilder < ActionView::Helpers::FormBuilder

    @@default_text_field_size = 50
    @@all_fields_required_by_default = true
    @@required_string = proc { %{<abbr title="#{I18n.t 'formtastic.required', :default => 'required'}">*</abbr>} }
    @@optional_string = ''
    @@inline_errors = :sentence
    @@label_str_method = :to_s
    @@collection_label_methods = %w[to_label display_name full_name name title username login value to_s]
    @@inline_order = [ :input, :hints, :errors ]

    cattr_accessor :default_text_field_size, :all_fields_required_by_default, :required_string, :optional_string, :inline_errors, :label_str_method, :collection_label_methods, :inline_order

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
      options[:label] ||= @object.class.human_attribute_name(method.to_s).send(@@label_str_method)
      options[:as] ||= default_input_type(@object, method)
      input_method = "#{options[:as]}_input"

      html_class = [
        options[:as].to_s,
        (options[:required] ? 'required' : 'optional'),
        (@object.errors.on(method.to_s) ? 'error' : nil)
      ].compact.join(" ")

      html_id = generate_html_id(method)

      list_item_content = @@inline_order.map do |type|
        if type == :input
          send(input_method, method, options)
        else
          send(:"inline_#{type}", method, options)
        end
      end.compact.join("\n")

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
    #
    # === Nested attributes
    #
    # As in Rails, you can use semantic_fields_for to nest attributes:
    #
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs :title, :body %>
    #
    #     <% form.semantic_fields_for :author, @bob do |author_form| %>
    #       <% author_form.inputs do %>
    #         <%= author_form.input :first_name, :required => false %>
    #         <%= author_form.input :last_name %>
    #       <% end %>
    #     <% end %>
    #   <% end %>
    #
    # But this does not look formtastic! This is equivalent:
    #
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs :title, :body %>
    #     <% form.inputs :for => [ :author, @bob ] do |author_form| %>
    #       <%= author_form.input :first_name, :required => false %>
    #       <%= author_form.input :last_name %>
    #     <% end %>
    #   <% end %>
    #
    # And if you don't need to give options to your input call, you could do it
    # in just one line:
    #
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs :title, :body %>
    #     <%= form.inputs :first_name, :last_name, :for => @bob %>
    #   <% end %>
    #
    # Just remember that calling inputs generates a new fieldset to wrap your
    # inputs. If you have two separate models, but, semantically, on the page
    # they are part of the same fieldset, you should use semantic_fields_for
    # instead (just as you would do with Rails' form builder).
    #
    def inputs(*args, &block)
      html_options = args.extract_options!
      html_options[:class] ||= "inputs"

      if fields_for_object = html_options.delete(:for)
        inputs_for_nested_attributes(fields_for_object, args << html_options,
                                     html_options.delete(:for_options) || {}, &block)
      elsif block_given?
        field_set_and_list_wrapping(html_options, &block)
      else
        if args.empty?
          args  = @object.class.reflections.map { |n,_| n }
          args += @object.class.content_columns.map(&:name)
        end
        contents = args.map { |method| input(method.to_sym) }

        field_set_and_list_wrapping(html_options, contents)
      end
    end
    alias :input_field_set :inputs

    # Creates a fieldset and ol tag wrapping for form buttons / actions as list items.
    # See inputs documentation for a full example.  The fieldset's default class attriute
    # is set to "buttons".
    #
    # See inputs for html attributes and special options.
    def buttons(*args, &block)
      html_options = args.extract_options!
      html_options[:class] ||= "buttons"

      if block_given?
        field_set_and_list_wrapping(html_options, &block)
      else
        args = [:commit] if args.empty?
        contents = args.map { |button_name| send(:"#{button_name}_button") }
        field_set_and_list_wrapping(html_options, contents)
      end
    end
    alias :button_field_set :buttons

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

    # Deals with :for option when it's supplied to inputs methods. Additional
    # options to be passed down to :for should be supplied using :for_options
    # key.
    #
    # It should raise an error if a block with arity zero is given.
    #
    def inputs_for_nested_attributes(fields_for_object, inputs, options, &block)
      fields_for_block = if block_given?
        raise ArgumentError, 'You gave :for option with a block to inputs method, ' <<
                             'but the block does not accept any argument.' if block.arity <= 0

        proc { |f| f.inputs(*inputs){ block.call(f) } }
      else
        proc { |f| f.inputs(*inputs) }
      end

      semantic_fields_for(*(Array(fields_for_object) << options), &fields_for_block)
    end

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
      prefix = @object.new_record? ? 'create' : 'save'
      [ I18n.t(prefix, :default => prefix, :scope => [:formtastic]),
        @object.class.human_name
      ].join(' ').send(@@label_str_method)
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

      if @object.class.respond_to?(:reflect_on_all_validations)
        attribute_sym = attribute.to_s.sub(/_id$/, '').to_sym
        @object.class.reflect_on_all_validations.any? do |validation|
          validation.macro == :validates_presence_of && validation.name == attribute_sym
        end
      else
        @@all_fields_required_by_default
      end
    end

    # Outputs a label and a select box containing options from the parent
    # (belongs_to, has_many, has_and_belongs_to_many) association. If an association
    # is has_many or has_and_belongs_to_many the select box will be set as multi-select
    # and size = 5
    #
    # Example (belongs_to):
    #
    #   f.input :author
    #
    #   <label for="book_author_id">Author</label>
    #   <select id="book_author_id" name="book[author_id]">
    #     <option value="1">Justin French</option>
    #     <option value="2">Jane Doe</option>
    #   </select>
    #
    # Example (has_many):
    #
    #   f.input :chapters
    #
    #   <label for="book_chapter_ids">Chapters</label>
    #   <select id="book_chapter_ids" name="book[chapter_ids]">
    #     <option value="1">Chapter 1</option>
    #     <option value="2">Chapter 2</option>
    #   </select>
    #
    # Example (has_and_belongs_to_many):
    #
    #   f.input :authors
    #
    #   <label for="book_author_ids">Authors</label>
    #   <select id="book_author_ids" name="book[author_ids]">
    #     <option value="1">Justin French</option>
    #     <option value="2">Jane Doe</option>
    #   </select>
    #
    #
    # You can customize the options available in the select by passing in a collection (Array) of
    # ActiveRecord objects through the :collection option.  If not provided, the choices are found
    # by inferring the parent's class name from the method name and simply calling find(:all) on
    # it (VehicleOwner.find(:all) in the example above).
    #
    # Examples:
    #
    #   f.input :author, :collection => @authors
    #   f.input :author, :collection => Author.find(:all)
    #   f.input :author, :collection => [@justin, @kate]
    #   f.input :author, :collection => {@justin.name => @justin.id, @kate.name => @kate.id}
    #
    # Note: This input looks for a label method in the parent association.
    #
    # You can customize the text label inside each option tag, by naming the correct method
    # (:full_name, :display_name, :account_number, etc) to call on each object in the collection
    # by passing in the :label_method option.  By default the :label_method is whichever element of
    # Formtastic::SemanticFormBuilder.collection_label_methods is found first.
    #
    # Examples:
    #
    #   f.input :author, :label_method => :full_name
    #   f.input :author, :label_method => :display_name
    #   f.input :author, :label_method => :to_s
    #   f.input :author, :label_method => :label
    #
    # You can also customize the value inside each option tag, by passing in the :value_method option.
    # Usage is the same as the :label_method option
    #
    # Examples:
    #
    #   f.input :author, :value_method => :full_name
    #   f.input :author, :value_method => :display_name
    #   f.input :author, :value_method => :to_s
    #   f.input :author, :value_method => :value
    #
    # You can pass html_options to the select tag using :input_html => {}
    #
    # Examples:
    #
    #   f.input :authors, :html => {:size => 20, :multiple => true}
    def select_input(method, options)
      options[:collection] ||= find_parent_objects_for_column(method)
      options[:label_method] ||= detect_label_method(options[:collection])
      options[:value_method] ||= :id
      options[:input_html] ||= {}

      if (reflection = find_reflection(method)) && reflection.macro != :belongs_to
        options[:input_html][:multiple] ||= true
        options[:input_html][:size] ||= 5
      end

      input_name = generate_association_input_name(method)
      html_options = options.delete(:input_html)
      choices = formatted_collection(options[:collection], options[:label_method], options[:value_method])
      input_label(input_name, options) + template.select(@object_name, input_name, choices, set_options(options), html_options)
    end

    def detect_label_method(collection) #:nodoc:
      (!collection.instance_of?(Hash)) ? @@collection_label_methods.detect { |m| collection.first.respond_to?(m) } : nil
    end

    def formatted_collection(collection, label_method, value_method = :id) #:nodoc:
      return collection if (collection.instance_of?(Hash) ||
                           (collection.instance_of?(Array) && [Array, String, Fixnum].include?(collection.first.class)))
      collection.map { |o| [o.send(label_method), o.send(value_method)] }
    end

    # Outputs a fieldset containing a legend for the label text, and an ordered list (ol) of list
    # items, one for each possible choice in the belongs_to association.  Each li contains a
    # label and a radio input.
    #
    # Example:
    #
    #   f.input :author, :as => :radio
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
    #   f.input :author, :as => :radio, :collection => @authors
    #   f.input :author, :as => :radio, :collection => Author.find(:all)
    #   f.input :author, :as => :radio, :collection => [@justin, @kate]
    #
    # You can also customize the text label inside each option tag, by naming the correct method
    # (:full_name, :display_name, :account_number, etc) to call on each object in the collection
    # by passing in the :label_method option.  By default the :label_method is whichever element of
    # Formtastic::SemanticFormBuilder.collection_label_methods is found first.
    #
    # Examples:
    #
    #   f.input :author, :as => :radio, :label_method => :full_name
    #   f.input :author, :as => :radio, :label_method => :display_name
    #   f.input :author, :as => :radio, :label_method => :to_s
    #   f.input :author, :as => :radio, :label_method => :label
    #
    # Finally, you can set :value_as_class => true if you want that LI wrappers
    # contains a class with the wrapped radio input value. This is used by
    # <tt>boolean_radio_input</tt> and you can see an example there.
    #
    def radio_input(method, options)
      options[:collection] ||= find_parent_objects_for_column(method)
      options[:label_method] ||= detect_label_method(options[:collection])

      input_name = generate_association_input_name(method)
      value_as_class = options.delete(:value_as_class)

      choices = formatted_collection(options[:collection], options[:label_method])
      template.content_tag(:fieldset,
        %{<legend><span>#{label_text(method, options)}</span></legend>} +
        template.content_tag(:ol,
          choices.map { |c|
            label = (!c.instance_of?(String)) ? c.first : c
            value = (!c.instance_of?(String)) ? c.last : c

            li_content = template.content_tag(:label,
              "#{template.radio_button(@object_name, input_name, value, set_options(options))} #{label}",
              :for => generate_html_id(input_name, value.to_s.downcase)
            )

            li_options = value_as_class ? { :class => value.to_s.downcase } : {}
            template.content_tag(:li, li_content, li_options)
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
    # This is an absolute abomination, but so is the official Rails select_date().
    #
    def date_or_datetime_input(method, options)
      position = { :year => 1, :month => 2, :day => 3, :hour => 4, :minute => 5, :second => 6 }
      inputs = options.delete(:order) || I18n.translate(:'date.order') || [:year, :month, :day]
      time_inputs = [:hour, :minute]
      time_inputs << [:second] if options[:include_seconds]

      # Gets the datetime object. It can be a Fixnum, Date or Time, or nil.
      datetime = @object.send(method)

      list_items_capture = ""
      (inputs + time_inputs).each do |input|
        html_id = generate_html_id(method, "#{position[input]}i")

        if options["discard_#{input}".intern]
          break if time_inputs.include?(input)
          hidden_value = datetime.respond_to?(input) ? datetime.send(input) : datetime
          list_items_capture << template.hidden_field_tag("#{@object_name}[#{method}(#{position[input]}i)]", (hidden_value || 1), :id => html_id)
        else
          opts = set_options(options).merge(:prefix => @object_name, :field_name => "#{method}(#{position[input]}i)")
          item_label_text = I18n.t(input.to_s, :default => input.to_s, :scope => [:formtastic]).send(@@label_str_method)
          list_items_capture << template.content_tag(:li,
            template.content_tag(:label, item_label_text, :for => html_id) +
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
    def boolean_select_input(method, options)
      options[:true]  ||= I18n.t('yes', :default => 'Yes', :scope => [:formtastic]).send(@@label_str_method)
      options[:false] ||= I18n.t('no', :default => 'No', :scope => [:formtastic]).send(@@label_str_method)

      choices = [ [options.delete(:true),true], [options.delete(:false),false] ]
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
    #        <li class="true">
    #          <label for="post_public_true">
    #            <input id="post_public_true" name="post[public]" type="radio" value="true" /> Yeah!
    #          </label>
    #        </li>
    #        <li class="false">
    #          <label for="post_public_false">
    #            <input id="post_public_false" name="post[public]" type="radio" checked="checked" /> Nah!
    #          </label>
    #        </li>
    #      </ol>
    #    </fieldset>
    #  </li>
    #
    def boolean_radio_input(method, options)
      options[:true]  ||= I18n.t('yes', :default => 'Yes', :scope => [:formtastic]).send(@@label_str_method)
      options[:false] ||= I18n.t('no', :default => 'No', :scope => [:formtastic]).send(@@label_str_method)

      choices = { options.delete(:true) => true, options.delete(:false) => false }
      radio_input(method, { :collection => choices, :value_as_class => true }.merge(options))
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
      template.label(@object_name, method, text, set_options(options))
    end

    def required_or_optional_string(required) #:nodoc:
      string_or_proc = required ? @@required_string : @@optional_string

      if string_or_proc.is_a? Proc
        string_or_proc.call
      else
        string_or_proc
      end
    end

    def field_set_and_list_wrapping(field_set_html_options, contents = '', &block) #:nodoc:
      legend_text = field_set_html_options.delete(:name)
      legend = legend_text.blank? ? "" : template.content_tag(:legend, template.content_tag(:span, legend_text))

      contents = template.capture(&block) if block_given?

      fieldset = template.content_tag(:fieldset,
        legend + template.content_tag(:ol, contents),
        field_set_html_options
      )

      template.concat(fieldset) if block_given?
      fieldset
    end

    # For methods that have a database column, take a best guess as to what the inout method
    # should be.  In most cases, it will just return the column type (eg :string), but for special
    # cases it will simplify (like the case of :integer, :float & :decimal to :numeric), or do
    # something different (like :password and :select).
    #
    # If there is no column for the method (eg "virtual columns" with an attr_accessor), the
    # default is a :string, a similar behaviour to Rails' scaffolding.
    def default_input_type(object, method) #:nodoc:
      # Find the column object by attribute
      column = object.column_for_attribute(method) if object.respond_to?(:column_for_attribute)
      # Maybe the column is a reflection?
      column = find_reflection(method) unless column

      if column
        # handle the special cases where the column type doesn't map to an input method
        return :select if column.respond_to?(:macro) && column.respond_to?(:klass)
        return :select if column.type == :integer && method.to_s =~ /_id$/
        return :datetime if column.type == :timestamp
        return :numeric if [:integer, :float, :decimal].include?(column.type)
        return :password if column.type == :string && method.to_s =~ /password/
        # otherwise assume the input name will be the same as the column type (eg string_input)
        return column.type
      else
        obj = object.send(method)
        return :file if [:file?, :public_filename].any? { |m| obj.respond_to?(m) }
        return :password if method.to_s =~ /password/
        return :string
      end
    end

    # Used by association inputs (select, radio) to get a default collection from the parent object
    # by determining the classname from the method/column name (section_id => Section) and doing a
    # simple find(:all).
    def find_parent_objects_for_column(column)
      parent_class = if reflection = find_reflection(column)
        reflection.klass
      else
        ::ActiveSupport::Deprecation.warn("The _id way of doing things is deprecated. Please use the association method (#{column.to_s.sub(/_id$/,'')})", caller[3..-1])
        column.to_s.sub(/_id$/,'').camelize.constantize
      end
      parent_class.find(:all)
    end

    # Used by association inputs (select, radio) to generate the name that should be used for the input
    # belongs_to :author; f.input :author; will generate 'author_id'
    # has_many :authors; f.input :authors; will generate 'author_ids'
    # has_and_belongs_to_many will act like has_many
    def generate_association_input_name(method)
      if reflection = find_reflection(method)
        method = "#{method.to_s.singularize}_id"
        method = method.pluralize if [:has_and_belongs_to_many, :has_many].include?(reflection.macro)
      end
      method
    end

    # If an association method is passed in (f.input :author) try to find the reflection object
    def find_reflection(method)
      object.class.reflect_on_association(method) if object.class.respond_to?(:reflect_on_association)
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
        { :size => @@default_text_field_size }
      else
        { :maxlength => column.limit, :size => [column.limit, @@default_text_field_size].min }
      end
      set_options(opts)
    end

    # Generate the html id for the li tag.
    # It takes into account options[:index] and @auto_index to generate li
    # elements with appropriate index scope. It also sanitizes the object
    # and method names.
    #
    def generate_html_id(method_name, value='input')
      if options.has_key?(:index)
        index = "_#{options[:index]}"
      elsif defined?(@auto_index)
        index = "_#{@auto_index}"
      else
        index = ""
      end
      sanitized_method_name = method_name.to_s.sub(/\?$/,"")

      "#{sanitized_object_name}#{index}_#{sanitized_method_name}_#{value}"
    end

    def sanitized_object_name
      @sanitized_object_name ||= @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
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
    @@builder = Formtastic::SemanticFormBuilder

    # cattr_accessor :builder
    def self.builder=(val)
      @@builder = val
    end

    [:form_for, :fields_for, :form_remote_for, :remote_form_for].each do |meth|
      src = <<-END_SRC
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
