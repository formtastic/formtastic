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
    @@label_str_method = :humanize
    @@collection_label_methods = %w[to_label display_name full_name name title username login value to_s]
    @@inline_order = [ :input, :hints, :errors ]
    @@file_methods = [ :file?, :public_filename ]
    @@priority_countries = ["Australia", "Canada", "United Kingdom", "United States"]

    cattr_accessor :default_text_field_size, :all_fields_required_by_default, :required_string,
                   :optional_string, :inline_errors, :label_str_method, :collection_label_methods,
                   :inline_order, :file_methods, :priority_countries

    # Keeps simple mappings in a hash
    INPUT_MAPPINGS = {
      :string   => :text_field,
      :password => :password_field,
      :numeric  => :text_field,
      :text     => :text_area,
      :file     => :file_field
    }
    STRING_MAPPINGS = [ :string, :password, :numeric ]

    attr_accessor :template

    # Returns a suitable form input for the given +method+, using the database column information
    # and other factors (like the method name) to figure out what you probably want.
    #
    # Options:
    #
    # * :as - override the input type (eg force a :string to render as a :password field)
    # * :label - use something other than the method name as the label text, when false no label is printed
    # * :required - specify if the column is required (true) or not (false)
    # * :hint - provide some text to hint or help the user provide the correct information for a field
    # * :input_html - provide options that will be passed down to the generated input
    # * :wrapper_html - provide options that will be passed down to the li wrapper
    #
    # Input Types:
    #
    # Most inputs map directly to one of ActiveRecord's column types by default (eg string_input),
    # but there are a few special cases and some simplification (:integer, :float and :decimal
    # columns all map to a single numeric_input, for example).
    #
    # * :select (a select menu for associations) - default to association names
    # * :check_boxes (a set of check_box inputs for associations) - alternative to :select has_many and has_and_belongs_to_many associations
    # * :radio (a set of radio inputs for associations) - alternative to :select belongs_to associations
    # * :time_zone (a select menu with time zones)
    # * :password (a password input) - default for :string column types with 'password' in the method name
    # * :text (a textarea) - default for :text column types
    # * :date (a date select) - default for :date column types
    # * :datetime (a date and time select) - default for :datetime and :timestamp column types
    # * :time (a time select) - default for :time column types
    # * :boolean (a checkbox) - default for :boolean column types (you can also have booleans as :select and :radio)
    # * :string (a text field) - default for :string column types
    # * :numeric (a text field, like string) - default for :integer, :float and :decimal column types
    # * :country (a select menu of country names) - requires a country_select plugin to be installed
    # * :hidden (a hidden field) - creates a hidden field (added for compatibility)
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
    #
    def input(method, options = {})
      options[:required] = method_required?(method) unless options.key?(:required)
      options[:as]     ||= default_input_type(method)

      html_class = [ options[:as], (options[:required] ? :required : :optional) ]
      html_class << 'error' if @object && @object.respond_to?(:errors) && @object.errors.on(method.to_s)

      wrapper_html = options.delete(:wrapper_html) || {}
      wrapper_html[:id]  ||= generate_html_id(method)
      wrapper_html[:class] = (html_class << wrapper_html[:class]).flatten.compact.join(' ')

      if [:boolean_select, :boolean_radio].include?(options[:as])
        ::ActiveSupport::Deprecation.warn(":as => :#{options[:as]} is deprecated, use :as => :#{options[:as].to_s[8..-1]} instead", caller[3..-1])
      end

      list_item_content = @@inline_order.map do |type|
        send(:"inline_#{type}_for", method, options)
      end.compact.join("\n")

      return template.content_tag(:li, list_item_content, wrapper_html)
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

      if html_options[:for]
        inputs_for_nested_attributes(args, html_options, &block)
      elsif block_given?
        field_set_and_list_wrapping(html_options, &block)
      else
        if @object && args.empty?
          args  = @object.class.reflections.map { |n,_| n if _.macro == :belongs_to }
          args += @object.class.content_columns.map(&:name)
          args -= %w[created_at updated_at created_on updated_on lock_version]
          args.compact!
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
    #
    # And you can pass html atributes down to the input, with or without the button text:
    #
    #  <%= form.commit_button "Go" %> => <input name="commit" type="submit" value="Go" />
    #  <%= form.commit_button :class => "pretty" %> => <input name="commit" type="submit" value="Save Post" class="pretty" />
    
    def commit_button(*args)
      value = args.first.is_a?(String) ? args.shift : save_or_create_button_text
      options = args.shift || {}
      button_html = options.delete(:button_html) || {}
      template.content_tag(:li, self.submit(value, button_html), :class => "commit")
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
    #
    def semantic_fields_for(record_or_name_or_array, *args, &block)
      opts = args.extract_options!
      opts.merge!(:builder => Formtastic::SemanticFormBuilder)
      args.push(opts)
      fields_for(record_or_name_or_array, *args, &block)
    end

    # Generates the label for the input. It also accepts the same arguments as
    # Rails label method. It has three options that are not supported by Rails
    # label method:
    #
    # * :required - Appends an abbr tag if :required is true
    # * :label - An alternative form to give the label content. Whenever label
    #            is false, a blank string is returned.
    # * :as_span - When true returns a span tag with class label instead of a label element
    #
    # == Examples
    #
    #  f.label :title # like in rails, except that it searches the label on I18n API too
    #
    #  f.label :title, "Your post title"
    #  f.label :title, :label => "Your post title" # Added for formtastic API
    #
    #  f.label :title, :required => true # Returns <label>Title<abbr title="required">*</abbr></label>
    #
    def label(method, options_or_text=nil, options=nil)
      if options_or_text.is_a?(Hash)
        return if options_or_text[:label] == false

        options = options_or_text
        text    = options.delete(:label)
      else
        text      = options_or_text
        options ||= {}
      end

      text ||= humanized_attribute_name(method)
      text  << required_or_optional_string(options.delete(:required))

      if options.delete(:as_span)
        options[:class] ||= 'label'
        template.content_tag(:span, text, options)
      else
        super(method, text, options)
      end
    end

    # Generates error messages for the given method. Errors can be shown as list
    # or as sentence. If :none is set, no error is shown.
    #
    # This method is also aliased as errors_on, so you can call on your custom
    # inputs as well:
    #
    #   semantic_form_for :post do |f|
    #     f.text_field(:body)
    #     f.errors_on(:body)
    #   end
    #
    def inline_errors_for(method, options=nil) #:nodoc:
      return nil unless @object && @object.respond_to?(:errors) && [:sentence, :list].include?(@@inline_errors)

      errors = @object.errors.on(method.to_s)
      send("error_#{@@inline_errors}", Array(errors)) unless errors.blank?
    end
    alias :errors_on :inline_errors_for

    protected

    # Deals with :for option when it's supplied to inputs methods. Additional
    # options to be passed down to :for should be supplied using :for_options
    # key.
    #
    # It should raise an error if a block with arity zero is given.
    #
    def inputs_for_nested_attributes(args, options, &block)
      args << options.merge!(:parent => { :builder => self, :for => options[:for] })

      fields_for_block = if block_given?
        raise ArgumentError, 'You gave :for option with a block to inputs method, ' <<
                             'but the block does not accept any argument.' if block.arity <= 0

        proc { |f| f.inputs(*args){ block.call(f) } }
      else
        proc { |f| f.inputs(*args) }
      end

      fields_for_args = [options.delete(:for), options.delete(:for_options) || {}].flatten
      semantic_fields_for(*fields_for_args, &fields_for_block)
    end

    # Remove any Formtastic-specific options before passing the down options.
    #
    def set_options(options)
      options.except(:value_method, :label_method, :collection, :required, :label,
                     :as, :hint, :input_html, :label_html, :value_as_class)
    end

    # Create a default button text. If the form is working with a object, it
    # defaults to "Create model" or "Save model" depending if we are working
    # with a new_record or not.
    #
    # When not working with models, it defaults to "Submit object".
    #
    def save_or_create_button_text(prefix='Submit') #:nodoc:
      if @object
        prefix      = @object.new_record? ? 'Create' : 'Save'
        object_name = @object.class.human_name
      else
        object_name = @object_name.to_s.send(@@label_str_method)
      end

      I18n.t(prefix.downcase, :default => prefix, :scope => [:formtastic]) << ' ' << object_name
    end

    # Determins if the attribute (eg :title) should be considered required or not.
    #
    # * if the :required option was provided in the options hash, the true/false value will be
    #   returned immediately, allowing the view to override any guesswork that follows:
    #
    # * if the :required option isn't provided in the options hash, and the ValidationReflection
    #   plugin is installed (http://github.com/redinger/validation_reflection), true is returned
    #   if the validates_presence_of macro has been used in the class for this attribute, or false
    #   otherwise.
    #
    # * if the :required option isn't provided, and the plugin isn't available, the value of the
    #   configuration option @@all_fields_required_by_default is used.
    #
    def method_required?(attribute) #:nodoc:
      if @object && @object.class.respond_to?(:reflect_on_all_validations)
        attribute_sym = attribute.to_s.sub(/_id$/, '').to_sym

        @object.class.reflect_on_all_validations.any? do |validation|
          validation.macro == :validates_presence_of && validation.name == attribute_sym
        end
      else
        @@all_fields_required_by_default
      end
    end

    # A method that deals with most of inputs (:string, :password, :file,
    # :textarea and :numeric). :select, :radio, :boolean and :datetime inputs
    # are not handled by this method, since they need more detailed approach.
    #
    # If input_html is given as option, it's passed down to the input.
    #
    def input_simple(type, method, options)
      html_options = options.delete(:input_html) || {}
      html_options = default_string_options(method).merge(html_options) if STRING_MAPPINGS.include?(type)

      self.label(method, options.slice(:label, :required)) +
      self.send(INPUT_MAPPINGS[type], method, html_options)
    end

    # Outputs a hidden field inside the wrapper, which should be hidden with CSS.
    # Additionals options can be given and will be sent straight to hidden input
    # element.
    #
    def hidden_input(method, options)
      self.hidden_field(method, set_options(options))
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
    #     <option value=""></option>
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
    #     <option value=""></option>
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
    #     <option value=""></option>
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
    #   f.input :authors, :input_html => {:size => 20, :multiple => true}
    #
    # By default, all select inputs will have a blank option at the top of the list. You can add
    # a prompt with the :prompt option, or disable the blank option with :include_blank => false.
    #
    def select_input(method, options)
      collection = find_collection_for_column(method, options)
      html_options = options.delete(:input_html) || {}

      unless options.key?(:include_blank) || options.key?(:prompt)
        options[:include_blank] = true
      end

      reflection = find_reflection(method)
      if reflection && [ :has_many, :has_and_belongs_to_many ].include?(reflection.macro)
        html_options[:multiple] ||= true
        html_options[:size]     ||= 5
       end

      input_name = generate_association_input_name(method)
      self.label(input_name, options.slice(:label, :required)) +
      self.select(input_name, collection, set_options(options), html_options)
    end
    alias :boolean_select_input :select_input

    # Outputs a timezone select input as Rails' time_zone_select helper. You
    # can give priority zones as option.
    #
    # Examples:
    #
    #   f.input :time_zone, :as => :time_zone, :priority_zones => /Australia/
    #
    def time_zone_input(method, options)
      html_options = options.delete(:input_html) || {}

      self.label(method, options.slice(:label, :required)) +
      self.time_zone_select(method, options.delete(:priority_zones), set_options(options), html_options)
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
    # it (Author.find(:all) in the example above).
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
    # contains a class with the wrapped radio input value.
    #
    def radio_input(method, options)
      collection   = find_collection_for_column(method, options)
      html_options = set_options(options).merge(options.delete(:input_html) || {})

      input_name = generate_association_input_name(method)
      value_as_class = options.delete(:value_as_class)

      list_item_content = collection.map do |c|
        label = c.is_a?(Array) ? c.first : c
        value = c.is_a?(Array) ? c.last  : c

        li_content = template.content_tag(:label,
          "#{self.radio_button(input_name, value, html_options)} #{label}",
          :for => generate_html_id(input_name, value.to_s.downcase)
        )

        li_options = value_as_class ? { :class => value.to_s.downcase } : {}
        template.content_tag(:li, li_content, li_options)
      end

      field_set_and_list_wrapping_for_method(method, options, list_item_content)
    end
    alias :boolean_radio_input :radio_input

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
      inputs   = options.delete(:order) || I18n.translate(:'date.order') || [:year, :month, :day]

      time_inputs = [:hour, :minute]
      time_inputs << [:second] if options[:include_seconds]

      list_items_capture = ""
      hidden_fields_capture = ""

      # Gets the datetime object. It can be a Fixnum, Date or Time, or nil.
      datetime     = @object ? @object.send(method) : nil
      html_options = options.delete(:input_html) || {}

      (inputs + time_inputs).each do |input|
        html_id    = generate_html_id(method, "#{position[input]}i")
        field_name = "#{method}(#{position[input]}i)"
        if options["discard_#{input}".intern]
          break if time_inputs.include?(input)
          
          hidden_value = datetime.respond_to?(input) ? datetime.send(input) : datetime
          hidden_fields_capture << template.hidden_field_tag("#{@object_name}[#{field_name}]", (hidden_value || 1), :id => html_id)
        else
          opts = set_options(options).merge(:prefix => @object_name, :field_name => field_name)
          item_label_text = I18n.t(input.to_s, :default => input.to_s.humanize, :scope => [:datetime, :prompts])

          list_items_capture << template.content_tag(:li,
            template.content_tag(:label, item_label_text, :for => html_id) +
            template.send("select_#{input}".intern, datetime, opts, html_options.merge(:id => html_id))
          )
        end
      end

      hidden_fields_capture + field_set_and_list_wrapping_for_method(method, options, list_items_capture)
    end


    # Outputs a fieldset containing a legend for the label text, and an ordered list (ol) of list
    # items, one for each possible choice in the belongs_to association.  Each li contains a
    # label and a check_box input.
    #
    # This is an alternative for has many and has and belongs to many associations.
    #
    # Example:
    #
    #   f.input :author, :as => :check_boxes
    #
    # Output:
    #
    #   <fieldset>
    #     <legend><span>Authors</span></legend>
    #     <ol>
    #       <li>
    #         <input type="hidden" name="book[author_id][1]" value="">
    #         <label for="book_author_id_1"><input id="book_author_id_1" name="book[author_id][1]" type="checkbox" value="1" /> Justin French</label>
    #       </li>
    #       <li>
    #         <input type="hidden" name="book[author_id][2]" value="">
    #         <label for="book_author_id_2"><input id="book_author_id_2" name="book[owner_id][2]" type="checkbox" value="2" /> Kate French</label>
    #       </li>
    #     </ol>
    #   </fieldset>
    #
    # Notice that the value of the checkbox is the same as the id and the hidden
    # field has empty value. You can override the hidden field value using the
    # unchecked_value option.
    #
    # You can customize the options available in the set by passing in a collection (Array) of
    # ActiveRecord objects through the :collection option.  If not provided, the choices are found
    # by inferring the parent's class name from the method name and simply calling find(:all) on
    # it (Author.find(:all) in the example above).
    #
    # Examples:
    #
    #   f.input :author, :as => :check_boxes, :collection => @authors
    #   f.input :author, :as => :check_boxes, :collection => Author.find(:all)
    #   f.input :author, :as => :check_boxes, :collection => [@justin, @kate]
    #
    # You can also customize the text label inside each option tag, by naming the correct method
    # (:full_name, :display_name, :account_number, etc) to call on each object in the collection
    # by passing in the :label_method option.  By default the :label_method is whichever element of
    # Formtastic::SemanticFormBuilder.collection_label_methods is found first.
    #
    # Examples:
    #
    #   f.input :author, :as => :check_boxes, :label_method => :full_name
    #   f.input :author, :as => :check_boxes, :label_method => :display_name
    #   f.input :author, :as => :check_boxes, :label_method => :to_s
    #   f.input :author, :as => :check_boxes, :label_method => :label
    #
    # You can set :value_as_class => true if you want that LI wrappers contains
    # a class with the wrapped checkbox input value.
    #
    def check_boxes_input(method, options)
      collection = find_collection_for_column(method, options)
      html_options = options.delete(:input_html) || {}

      input_name      = generate_association_input_name(method)
      value_as_class  = options.delete(:value_as_class)
      unchecked_value = options.delete(:unchecked_value) || ''
      html_options    = { :name => "#{@object_name}[#{input_name}][]" }.merge(html_options)

      list_item_content = collection.map do |c|
        label = c.is_a?(Array) ? c.first : c
        value = c.is_a?(Array) ? c.last : c

        html_options.merge!(:id => generate_html_id(input_name, value.to_s.downcase))
 
        li_content = template.content_tag(:label,
          "#{self.check_box(input_name, html_options, value, unchecked_value)} #{label}",
          :for => html_options[:id]
        )

        li_options = value_as_class ? { :class => value.to_s.downcase } : {}
        template.content_tag(:li, li_content, li_options)
      end

      field_set_and_list_wrapping_for_method(method, options, list_item_content)
    end
    
    
    # Outputs a country select input, wrapping around a regular country_select helper. 
    # Rails doesn't come with a country_select helper by default any more, so you'll need to install
    # the "official" plugin, or, if you wish, any other country_select plugin that behaves in the
    # same way.
    #
    # The Rails plugin iso-3166-country-select plugin can be found "here":http://github.com/rails/iso-3166-country-select.
    #
    # By default, Formtastic includes a handfull of english-speaking countries as "priority counties", 
    # which you can change to suit your market and user base (see README for more info on config).
    #
    # Examples:
    #   f.input :location, :as => :country # use Formtastic::SemanticFormBuilder.priority_countries array for the priority countries
    #   f.input :location, :as => :country, :priority_countries => /Australia/ # set your own
    #
    def country_input(method, options)
      raise "To use the :country input, please install a country_select plugin, like this one: http://github.com/rails/iso-3166-country-select" unless self.respond_to?(:country_select)
      
      html_options = options.delete(:input_html) || {}
      priority_countries = options.delete(:priority_countries) || @@priority_countries

      self.label(method, options.slice(:label, :required)) +
      self.country_select(method, priority_countries, set_options(options), html_options)
    end
    

    # Outputs a label containing a checkbox and the label text. The label defaults
    # to the column name (method name) and can be altered with the :label option.
    # :checked_value and :unchecked_value options are also available.
    #
    def boolean_input(method, options)
      html_options = options.delete(:input_html) || {}

      input = self.check_box(method, set_options(options).merge(html_options),
                             options.delete(:checked_value) || '1', options.delete(:unchecked_value) || '0')

      label = options.delete(:label) || humanized_attribute_name(method)
      self.label(method, input + label, options.slice(:required))
    end

    # Generates an input for the given method using the type supplied with :as.
    #
    # If the input is included in INPUT_MAPPINGS, it uses input_simple
    # implementation which maps most of the inputs. All others have specific
    # code and then a proper handler should be called (like radio_input) for
    # :radio types.
    #
    def inline_input_for(method, options)
      input_type = options.delete(:as)

      if INPUT_MAPPINGS.key?(input_type)
        input_simple(input_type,  method, options)
      else
        send("#{input_type}_input", method, options)
      end
    end

    # Generates hints for the given method using the text supplied in :hint.
    #
    def inline_hints_for(method, options) #:nodoc:
      return if options[:hint].blank?
      template.content_tag(:p, options[:hint], :class => 'inline-hints')
    end

    # Creates an error sentence by calling to_sentence on the errors array.
    #
    def error_sentence(errors) #:nodoc:
      template.content_tag(:p, errors.to_sentence.untaint, :class => 'inline-errors')
    end

    # Creates an error li list.
    #
    def error_list(errors) #:nodoc:
      list_elements = []
      errors.each do |error|
        list_elements <<  template.content_tag(:li, error.untaint)
      end
      template.content_tag(:ul, list_elements.join("\n"), :class => 'errors')
    end

    # Generates the required or optional string. If the value set is a proc,
    # it evaluates the proc first.
    #
    def required_or_optional_string(required) #:nodoc:
      string_or_proc = case required
        when true
          @@required_string
        when false
          @@optional_string
        else
          required
      end

      if string_or_proc.is_a?(Proc)
        string_or_proc.call
      else
        string_or_proc.to_s
      end
    end

    # Generates a fieldset and wraps the content in an ordered list. When working
    # with nested attributes (in Rails 2.3), it allows %i as interpolation option
    # in :name. So you can do:
    #
    #   f.inputs :name => 'Task #%i', :for => :tasks
    #
    # And it will generate a fieldset for each task with legend 'Task #1', 'Task #2',
    # 'Task #3' and so on.
    #
    def field_set_and_list_wrapping(html_options, contents='', &block) #:nodoc:
      legend  = html_options.delete(:name).to_s
      legend %= parent_child_index(html_options[:parent]) if html_options[:parent]
      legend  = template.content_tag(:legend, template.content_tag(:span, legend)) unless legend.blank?

      contents = template.capture(&block) if block_given?

      # Ruby 1.9: String#to_s behavior changed, need to make an explicit join.
      contents = contents.join if contents.respond_to?(:join)
      fieldset = template.content_tag(:fieldset,
        legend + template.content_tag(:ol, contents),
        html_options.except(:builder, :parent)
      )

      template.concat(fieldset) if block_given?
      fieldset
    end

    # Also generates a fieldset and an ordered list but with label based in
    # method. This methods is currently used by radio and datetime inputs.
    #
    def field_set_and_list_wrapping_for_method(method, options, contents)
      contents = contents.join if contents.respond_to?(:join)

      template.content_tag(:fieldset,
        %{<legend>#{self.label(method, options.slice(:label, :required).merge!(:as_span => true))}</legend>} +
        template.content_tag(:ol, contents)
      )
    end

    # For methods that have a database column, take a best guess as to what the input method
    # should be.  In most cases, it will just return the column type (eg :string), but for special
    # cases it will simplify (like the case of :integer, :float & :decimal to :numeric), or do
    # something different (like :password and :select).
    #
    # If there is no column for the method (eg "virtual columns" with an attr_accessor), the
    # default is a :string, a similar behaviour to Rails' scaffolding.
    #
    def default_input_type(method) #:nodoc:
      return :string if @object.nil?

      column = @object.column_for_attribute(method) if @object.respond_to?(:column_for_attribute)

      if column
        # handle the special cases where the column type doesn't map to an input method
        return :time_zone if column.type == :string && method.to_s =~ /time_zone/
        return :select    if column.type == :integer && method.to_s =~ /_id$/
        return :datetime  if column.type == :timestamp
        return :numeric   if [:integer, :float, :decimal].include?(column.type)
        return :password  if column.type == :string && method.to_s =~ /password/
        return :country   if column.type == :string && method.to_s =~ /country/

        # otherwise assume the input name will be the same as the column type (eg string_input)
        return column.type
      else
        obj = @object.send(method) if @object.respond_to?(method)

        return :select   if find_reflection(method)
        return :file     if obj && @@file_methods.any? { |m| obj.respond_to?(m) }
        return :password if method.to_s =~ /password/
        return :string
      end
    end

    # Used by select and radio inputs. The collection can be retrieved by
    # three ways:
    #
    # * Explicitly provided through :collection
    # * Retrivied through an association
    # * Or a boolean column, which will generate a localized { "Yes" => true, "No" => false } hash.
    #
    # If the collection is not a hash or an array of strings, fixnums or arrays,
    # we use label_method and value_method to retreive an array with the
    # appropriate label and value.
    #
    def find_collection_for_column(column, options)
      reflection = find_reflection(column)

      collection = if options[:collection]
        options.delete(:collection)
      elsif reflection || column.to_s =~ /_id$/
        parent_class = if reflection
          reflection.klass
        else
          ::ActiveSupport::Deprecation.warn("The _id way of doing things is deprecated. Please use the association method (#{column.to_s.sub(/_id$/,'')})", caller[3..-1])
          column.to_s.sub(/_id$/,'').camelize.constantize
        end

        parent_class.find(:all)
      else
        create_boolean_collection(options)
      end

      collection = collection.to_a if collection.instance_of?(Hash)

      # Return if we have an Array of strings, fixnums or arrays
      return collection if collection.instance_of?(Array) &&
                           [Array, Fixnum, String, Symbol].include?(collection.first.class)

      label = options.delete(:label_method) || detect_label_method(collection)
      value = options.delete(:value_method) || :id

      collection.map { |o| [o.send(label), o.send(value)] }
    end

    # Detected the label collection method when none is supplied using the
    # values set in @@collection_label_methods.
    #
    def detect_label_method(collection) #:nodoc:
      @@collection_label_methods.detect { |m| collection.first.respond_to?(m) }
    end

    # Returns a hash to be used by radio and select inputs when a boolean field
    # is provided.
    #
    def create_boolean_collection(options)
      options[:true] ||= I18n.t('yes', :default => 'Yes', :scope => [:formtastic])
      options[:false] ||= I18n.t('no', :default => 'No', :scope => [:formtastic])
      options[:value_as_class] = true unless options.key?(:value_as_class)

      { options.delete(:true) => true, options.delete(:false) => false }
    end

    # Used by association inputs (select, radio) to generate the name that should
    # be used for the input
    #
    #   belongs_to :author; f.input :author; will generate 'author_id'
    #   has_many :authors; f.input :authors; will generate 'author_ids'
    #   has_and_belongs_to_many will act like has_many
    #
    def generate_association_input_name(method)
      if reflection = find_reflection(method)
        if [:has_and_belongs_to_many, :has_many].include?(reflection.macro)
          "#{method.to_s.singularize}_ids"
        else
          "#{method}_id"
        end
      else
        method
      end
    end

    # If an association method is passed in (f.input :author) try to find the
    # reflection object.
    #
    def find_reflection(method)
      @object.class.reflect_on_association(method) if @object.class.respond_to?(:reflect_on_association)
    end

    # Generates default_string_options by retrieving column information from
    # the database.
    #
    def default_string_options(method) #:nodoc:
      column = @object.column_for_attribute(method) if @object.respond_to?(:column_for_attribute)

      if column.nil? || column.limit.nil?
        { :size => @@default_text_field_size }
      else
        { :maxlength => column.limit, :size => [column.limit, @@default_text_field_size].min }
      end
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

    # Gets the nested_child_index value from the parent builder. In Rails 2.3
    # it always returns a fixnum. In next versions it returns a hash with each
    # association that the parent builds.
    #
    def parent_child_index(parent)
      duck = parent[:builder].instance_variable_get('@nested_child_index')

      if duck.is_a?(Hash)
        child = parent[:for]
        child = child.first if child.respond_to?(:first)
        duck[child].to_i + 1
      else
        duck.to_i + 1
      end
    end

    def sanitized_object_name
      @sanitized_object_name ||= @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    end

    def humanized_attribute_name(method)
      if @object && @object.class.respond_to?(:human_attribute_name)
        @object.class.human_attribute_name(method.to_s)
      else
        method.to_s.send(@@label_str_method)
      end
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
  #
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
