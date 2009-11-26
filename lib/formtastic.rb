# coding: utf-8
require File.join(File.dirname(__FILE__), *%w[formtastic i18n])

module Formtastic #:nodoc:

  class SemanticFormBuilder < ActionView::Helpers::FormBuilder

    @@default_text_field_size = 50
    @@all_fields_required_by_default = true
    @@include_blank_for_select_by_default = true
    @@required_string = proc { %{<abbr title="#{::Formtastic::I18n.t(:required)}">*</abbr>} }
    @@optional_string = ''
    @@inline_errors = :sentence
    @@label_str_method = :humanize
    @@collection_label_methods = %w[to_label display_name full_name name title username login value to_s]
    @@inline_order = [ :input, :hints, :errors ]
    @@file_methods = [ :file?, :public_filename ]
    @@priority_countries = ["Australia", "Canada", "United Kingdom", "United States"]
    @@i18n_lookups_by_default = false
    @@default_commit_button_accesskey = nil 

    cattr_accessor :default_text_field_size, :all_fields_required_by_default, :include_blank_for_select_by_default,
                   :required_string, :optional_string, :inline_errors, :label_str_method, :collection_label_methods,
                   :inline_order, :file_methods, :priority_countries, :i18n_lookups_by_default, :default_commit_button_accesskey 

    RESERVED_COLUMNS = [:created_at, :updated_at, :created_on, :updated_on, :lock_version, :version]

    INLINE_ERROR_TYPES = [:sentence, :list, :first]

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
    #       <%= form.input :secret, :value => "Hello" %>
    #       <%= form.input :name, :label => "Full Name" %>
    #       <%= form.input :manager_id, :as => :radio %>
    #       <%= form.input :hired_at, :as => :date, :label => "Date Hired" %>
    #       <%= form.input :phone, :required => false, :hint => "Eg: +1 555 1234" %>
    #     <% end %>
    #   <% end %>
    #
    def input(method, options = {})
      options[:required] = method_required?(method) unless options.key?(:required)
      options[:as]     ||= default_input_type(method, options)

      html_class = [ options[:as], (options[:required] ? :required : :optional) ]
      html_class << 'error' if @object && @object.respond_to?(:errors) && !@object.errors[method.to_sym].blank?

      wrapper_html = options.delete(:wrapper_html) || {}
      wrapper_html[:id]  ||= generate_html_id(method)
      wrapper_html[:class] = (html_class << wrapper_html[:class]).flatten.compact.join(' ')

      if options[:input_html] && options[:input_html][:id]
        options[:label_html] ||= {}
        options[:label_html][:for] ||= options[:input_html][:id]
      end

      input_parts = @@inline_order.dup
      input_parts.delete(:errors) if options[:as] == :hidden

      list_item_content = input_parts.map do |type|
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
    #   With a few arguments:
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs "Post details", :title, :body %>
    #   <% end %>
    #
    # === Options
    #
    # All options (with the exception of :name/:title) are passed down to the fieldset as HTML
    # attributes (id, class, style, etc).  If provided, the :name/:title option is passed into a
    # legend tag inside the fieldset.
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
    #   # ...or the equivalent:
    #   <% semantic_form_for @post do |form| %>
    #     <%= form.inputs "Create a new post", :title, :body, :style => "border:1px;" %>
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
    #     <% f.inputs "Extra" do %>
    #       <%= f.input :update_at %>
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
    #     <fieldset class="inputs">
    #       <legend><span>Extra</span></legend>
    #       <ol>
    #         <li class="datetime">...</li>
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
      title = field_set_title_from_args(*args)
      html_options = args.extract_options!
      html_options[:class] ||= "inputs"
      html_options[:name] = title
      
      if html_options[:for] # Nested form
        inputs_for_nested_attributes(*(args << html_options), &block)
      elsif block_given?
        field_set_and_list_wrapping(*(args << html_options), &block)
      else
        if @object && args.empty?
          args  = self.association_columns(:belongs_to)
          args += self.content_columns
          args -= RESERVED_COLUMNS
          args.compact!
        end
        legend = args.shift if args.first.is_a?(::String)
        contents = args.collect { |method| input(method.to_sym) }
        args.unshift(legend) if legend.present?
        
        field_set_and_list_wrapping(*((args << html_options) << contents))
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
    #  <%= form.commit_button "Go" %> => <input name="commit" type="submit" value="Go" class="{create|update|submit}" />
    #  <%= form.commit_button :label => "Go" %> => <input name="commit" type="submit" value="Go" class="{create|update|submit}" />
    #
    # And you can pass html atributes down to the input, with or without the button text:
    #
    #  <%= form.commit_button "Go" %> => <input name="commit" type="submit" value="Go" class="{create|update|submit}" />
    #  <%= form.commit_button :class => "pretty" %> => <input name="commit" type="submit" value="Save Post" class="pretty {create|update|submit}" />
    #
    def commit_button(*args)
      options = args.extract_options!
      text = options.delete(:label) || args.shift

      if @object
        key = @object.new_record? ? :create : :update
        object_name = @object.class.human_name
      else
        key = :submit
        object_name = @object_name.to_s.send(@@label_str_method)
      end

      text = (self.localized_string(key, text, :action, :model => object_name) ||
              ::Formtastic::I18n.t(key, :model => object_name)) unless text.is_a?(::String)

      button_html = options.delete(:button_html) || {}
      button_html.merge!(:class => [button_html[:class], key].compact.join(' '))
      element_class = ['commit', options.delete(:class)].compact.join(' ') # TODO: Add class reflecting on form action.
      accesskey = (options.delete(:accesskey) || @@default_commit_button_accesskey) unless button_html.has_key?(:accesskey)
      button_html = button_html.merge(:accesskey => accesskey) if accesskey  
      template.content_tag(:li, self.submit(text, button_html), :class => element_class)
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
      opts[:builder] ||= Formtastic::SemanticFormHelper.builder
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
    # * :input_name - Gives the input to match for. This is needed when you want to
    #                 to call f.label :authors but it should match :author_ids.
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
        return "" if options_or_text[:label] == false
        options = options_or_text
        text = options.delete(:label)
      else
        text = options_or_text
        options ||= {}
      end
      text = localized_string(method, text, :label) || humanized_attribute_name(method)
      text += required_or_optional_string(options.delete(:required))

      # special case for boolean (checkbox) labels, which have a nested input
      text = (options.delete(:label_prefix_for_nested_input) || "") + text

      input_name = options.delete(:input_name) || method
      super(input_name, text, options)
    end

    # Generates error messages for the given method. Errors can be shown as list,
    # as sentence or just the first error can be displayed. If :none is set, no error is shown.
    #
    # This method is also aliased as errors_on, so you can call on your custom
    # inputs as well:
    #
    #   semantic_form_for :post do |f|
    #     f.text_field(:body)
    #     f.errors_on(:body)
    #   end
    #
    def inline_errors_for(method, options = nil) #:nodoc:
      if render_inline_errors?
        errors = @object.errors[method.to_sym]
        send(:"error_#{@@inline_errors}", [*errors]) if errors.present?
      else
        nil
      end
    end
    alias :errors_on :inline_errors_for

    protected

      def render_inline_errors?
        @object && @object.respond_to?(:errors) && INLINE_ERROR_TYPES.include?(@@inline_errors)
      end

      # Collects content columns (non-relation columns) for the current form object class.
      #
      def content_columns #:nodoc:
        self.model_name.constantize.content_columns.collect { |c| c.name.to_sym }.compact rescue []
      end

      # Collects association columns (relation columns) for the current form object class.
      #
      def association_columns(*by_associations) #:nodoc:
        if @object.present?
          @object.class.reflections.collect do |name, _|
            if by_associations.present?
              name if by_associations.include?(_.macro)
            else
              name
            end
          end.compact
        else
          []
        end
      end

      # Prepare options to be sent to label
      #
      def options_for_label(options) #:nodoc:
        options.slice(:label, :required).merge!(options.fetch(:label_html, {}))
      end

      # Deals with :for option when it's supplied to inputs methods. Additional
      # options to be passed down to :for should be supplied using :for_options
      # key.
      #
      # It should raise an error if a block with arity zero is given.
      #
      def inputs_for_nested_attributes(*args, &block) #:nodoc:
        options = args.extract_options!
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
      def strip_formtastic_options(options) #:nodoc:
        options.except(:value_method, :label_method, :collection, :required, :label,
                       :as, :hint, :input_html, :label_html, :value_as_class)
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
        if @object && @object.class.respond_to?(:reflect_on_validations_for)
          attribute_sym = attribute.to_s.sub(/_id$/, '').to_sym

          @object.class.reflect_on_validations_for(attribute_sym).any? do |validation|
            validation.macro == :validates_presence_of &&
            validation.name == attribute_sym &&
            (validation.options.present? ? options_require_validation?(validation.options) : true)
          end
        else
          @@all_fields_required_by_default
        end
      end

      # Determines whether the given options evaluate to true
      def options_require_validation?(options) #nodoc
        if_condition = !options[:if].nil?
        condition = if_condition ? options[:if] : options[:unless]

        condition = if condition.respond_to?(:call)
                      condition.call(@object)
                    elsif condition.is_a?(::Symbol) && @object.respond_to?(condition)
                      @object.send(condition)
                    else
                      condition
                    end

        if_condition ? !!condition : !condition
      end

      def basic_input_helper(form_helper_method, type, method, options) #:nodoc:
        html_options = options.delete(:input_html) || {}
        html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password].include?(type)

        self.label(method, options_for_label(options)) <<
        self.send(form_helper_method, method, html_options)
      end

      # Outputs a label and standard Rails text field inside the wrapper.
      def string_input(method, options)
        basic_input_helper(:text_field, :string, method, options)
      end

      # Outputs a label and standard Rails password field inside the wrapper.
      def password_input(method, options)
        basic_input_helper(:password_field, :password, method, options)
      end

      # Outputs a label and standard Rails text field inside the wrapper.
      def numeric_input(method, options)
        basic_input_helper(:text_field, :numeric, method, options)
      end

      # Ouputs a label and standard Rails text area inside the wrapper.
      def text_input(method, options)
        basic_input_helper(:text_area, :text, method, options)
      end

      # Outputs a label and a standard Rails file field inside the wrapper.
      def file_input(method, options)
        basic_input_helper(:file_field, :file, method, options)
      end

      # Outputs a hidden field inside the wrapper, which should be hidden with CSS.
      # Additionals options can be given and will be sent straight to hidden input
      # element.
      #
      def hidden_input(method, options)
        options ||= {}
        if options[:input_html].present?
          options[:value] = options[:input_html][:value] if options[:input_html][:value].present?
        end
        self.hidden_field(method, strip_formtastic_options(options))
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
      # You can customize the options available in the select by passing in a collection (an Array or 
      # Hash) through the :collection option.  If not provided, the choices are found by inferring the 
      # parent's class name from the method name and simply calling find(:all) on it 
      # (VehicleOwner.find(:all) in the example above).
      #
      # Examples:
      #
      #   f.input :author, :collection => @authors
      #   f.input :author, :collection => Author.find(:all)
      #   f.input :author, :collection => [@justin, @kate]
      #   f.input :author, :collection => {@justin.name => @justin.id, @kate.name => @kate.id}
      #   f.input :author, :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
      #
      # The :label_method option allows you to customize the text label inside each option tag two ways:
      #
      # * by naming the correct method to call on each object in the collection as a symbol (:name, :login, etc)
      # * by passing a Proc that will be called on each object in the collection, allowing you to use helpers or multiple model attributes together
      #
      # Examples:
      #
      #   f.input :author, :label_method => :full_name
      #   f.input :author, :label_method => :login
      #   f.input :author, :label_method => :full_name_with_post_count
      #   f.input :author, :label_method => Proc.new { |a| "#{a.name} (#{pluralize("post", a.posts.count)})" }
      #
      # The :value_method option provides the same customization of the value attribute of each option tag.
      #
      # Examples:
      #
      #   f.input :author, :value_method => :full_name
      #   f.input :author, :value_method => :login
      #   f.input :author, :value_method => Proc.new { |a| "author_#{a.login}" }
      #
      # You can pre-select a specific option value by passing in the :selected option.
      # 
      # Examples:
      #  
      #   f.input :author, :selected => current_user.id
      #   f.input :author, :value_method => :login, :selected => current_user.login
      #   f.input :authors, :value_method => :login, :selected => Author.most_popular.collect(&:id)
      #   f.input :authors, :value_method => :login, :selected => nil   # override any defaults: select none
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
      #
      # You can group the options in optgroup elements by passing the :group_by option 
      # (Note: only tested for belongs_to relations)
      # 
      # Examples:
      #
      #   f.input :author, :group_by => :continent
      # 
      # All the other options should work as expected. If you want to call a custom method on the 
      # group item. You can include the option:group_label_method
      # Examples:
      #
      #   f.input :author, :group_by => :continents, :group_label_method => :something_different
      #
      def select_input(method, options)
        html_options = options.delete(:input_html) || {}
        options = set_include_blank(options)
        html_options[:multiple] = options.delete(:multiple) if html_options[:multiple].nil?

        reflection = self.reflection_for(method)
        if reflection && [ :has_many, :has_and_belongs_to_many ].include?(reflection.macro)
          options[:include_blank]   = false
          html_options[:multiple] = true if html_options[:multiple].nil?
          html_options[:size]     ||= 5
        end
        options[:selected] = options[:selected].first if options[:selected].present? && html_options[:multiple] == false
        input_name = generate_association_input_name(method)

        select_html = if options[:group_by]
          # The grouped_options_select is a bit counter intuitive and not optimised (mostly due to ActiveRecord). 
          # The formtastic user however shouldn't notice this too much.
          raw_collection = find_raw_collection_for_column(method, options.reverse_merge(:find_options => { :include => options[:group_by] }))
          label, value = detect_label_and_value_method!(raw_collection)
          group_collection = raw_collection.map { |option| option.send(options[:group_by]) }.uniq
          group_label_method = options[:group_label_method] || detect_label_method(group_collection)
          group_collection = group_collection.sort_by { |group_item| group_item.send(group_label_method) }
          group_association = options[:group_association] || detect_group_association(method, options[:group_by])

          # Here comes the monster with 8 arguments
          self.grouped_collection_select(input_name, group_collection,
                                         group_association, group_label_method,
                                         value, label, 
                                         strip_formtastic_options(options), html_options)
        else
          collection = find_collection_for_column(method, options)
          self.select(input_name, collection, strip_formtastic_options(options), html_options)
        end

        self.label(method, options_for_label(options).merge(:input_name => input_name)) << select_html
      end
      alias :boolean_select_input :select_input

      # Outputs a timezone select input as Rails' time_zone_select helper. You
      # can give priority zones as option.
      #
      # Examples:
      #
      #   f.input :time_zone, :as => :time_zone, :priority_zones => /Australia/
      #
      # You can pre-select a specific option value by passing in the :selected option.
      # Note: Right now only works if the form object attribute value is not set (nil),
      # because of how the core helper is implemented.
      # 
      # Examples:
      #  
      #   f.input :my_favorite_time_zone, :as => :time_zone, :selected => 'Singapore'
      #
      def time_zone_input(method, options)
        html_options = options.delete(:input_html) || {}
        selected_value = options.delete(:selected)

        self.label(method, options_for_label(options)) <<
        self.time_zone_select(method, options.delete(:priority_zones),
          strip_formtastic_options(options).merge(:default => selected_value), html_options)
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
      # You can customize the choices available in the radio button set by passing in a collection (an Array or 
      # Hash) through the :collection option.  If not provided, the choices are found by reflecting on the association
      # (Author.find(:all) in the example above).
      #
      # Examples:
      #
      #   f.input :author, :as => :radio, :collection => @authors
      #   f.input :author, :as => :radio, :collection => Author.find(:all)
      #   f.input :author, :as => :radio, :collection => [@justin, @kate]
      #   f.input :author, :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
      #
      # The :label_method option allows you to customize the label for each radio button two ways:
      #
      # * by naming the correct method to call on each object in the collection as a symbol (:name, :login, etc)
      # * by passing a Proc that will be called on each object in the collection, allowing you to use helpers or multiple model attributes together
      #
      # Examples:
      #
      #   f.input :author, :as => :radio, :label_method => :full_name
      #   f.input :author, :as => :radio, :label_method => :login
      #   f.input :author, :as => :radio, :label_method => :full_name_with_post_count
      #   f.input :author, :as => :radio, :label_method => Proc.new { |a| "#{a.name} (#{pluralize("post", a.posts.count)})" }
      #
      # The :value_method option provides the same customization of the value attribute of each option tag.
      #
      # Examples:
      #
      #   f.input :author, :as => :radio, :value_method => :full_name
      #   f.input :author, :as => :radio, :value_method => :login
      #   f.input :author, :as => :radio, :value_method => Proc.new { |a| "author_#{a.login}" }
      # 
      # You can force a particular radio button in the collection to be checked with the :selected option.
      #
      # Examples:
      #
      #   f.input :subscribe_to_newsletter, :as => :radio, :selected => true
      #   f.input :subscribe_to_newsletter, :as => :radio, :collection => ["Yeah!", "Nope!"], :selected => "Nope!"
      #
      # Finally, you can set :value_as_class => true if you want the li wrapper around each radio 
      # button / label combination to contain a class with the value of the radio button (useful for
      # applying specific CSS or Javascript to a particular radio button).
      #
      def radio_input(method, options)
        collection   = find_collection_for_column(method, options)
        html_options = strip_formtastic_options(options).merge(options.delete(:input_html) || {})

        input_name = generate_association_input_name(method)
        value_as_class = options.delete(:value_as_class)
        input_ids = []
        selected_option_is_present = [:selected, :checked].any? { |k| options.key?(k) }
        selected_value = (options.key?(:checked) ? options[:checked] : options[:selected]) if selected_option_is_present

        list_item_content = collection.map do |c|
          label = c.is_a?(Array) ? c.first : c
          value = c.is_a?(Array) ? c.last  : c
          input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
          input_ids << input_id

          html_options[:checked] = selected_value == value if selected_option_is_present

          li_content = template.content_tag(:label,
            "#{self.radio_button(input_name, value, html_options)} #{label}",
            :for => input_id
          )

          li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
          template.content_tag(:li, li_content, li_options)
        end

        field_set_and_list_wrapping_for_method(method, options.merge(:label_for => input_ids.first), list_item_content)
      end
      alias :boolean_radio_input :radio_input

      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the date (year, month, day).  Each li contains a label
      # (eg "Year") and a select box.  See date_or_datetime_input for a more detailed output example.
      #
      # You can pre-select a specific option value by passing in the :selected option.
      # 
      # Examples:
      # 
      #   f.input :created_at, :as => :date, :selected => 1.day.ago
      #   f.input :created_at, :as => :date, :selected => nil   # override any defaults: select none
      #
      # Some of Rails' options for select_date are supported, but not everything yet.
      #
      def date_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options.merge(:discard_hour => true))
      end

      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the date (year, month, day, hour, min, sec).  Each li
      # contains a label (eg "Year") and a select box.  See date_or_datetime_input for a more
      # detailed output example.
      #
      # You can pre-select a specific option value by passing in the :selected option.
      # 
      # Examples:
      # 
      #   f.input :created_at, :as => :datetime, :selected => 1.day.ago
      #   f.input :created_at, :as => :datetime, :selected => nil   # override any defaults: select none
      #
      # Some of Rails' options for select_date are supported, but not everything yet.
      #
      def datetime_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options)
      end

      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the time (hour, minute, second).  Each li contains a label
      # (eg "Hour") and a select box.  See date_or_datetime_input for a more detailed output example.
      #
      # You can pre-select a specific option value by passing in the :selected option.
      # 
      # Examples:
      # 
      #   f.input :created_at, :as => :time, :selected => 1.hour.ago
      #   f.input :created_at, :as => :time, :selected => nil   # override any defaults: select none
      #
      # Some of Rails' options for select_time are supported, but not everything yet.
      #
      def time_input(method, options)
        options = set_include_blank(options)
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
        i18n_date_order = ::I18n.t(:order, :scope => [:date])
        i18n_date_order = nil unless i18n_date_order.is_a?(Array)
        inputs   = options.delete(:order) || i18n_date_order || [:year, :month, :day]

        time_inputs = [:hour, :minute]
        time_inputs << [:second] if options[:include_seconds]

        list_items_capture = ""
        hidden_fields_capture = ""

        default_time = ::Time.now

        # Gets the datetime object. It can be a Fixnum, Date or Time, or nil.
        datetime = options[:selected] || (@object ? @object.send(method) : default_time) || default_time
        
        html_options = options.delete(:input_html) || {}
        input_ids    = []

        (inputs + time_inputs).each do |input|
          input_ids << input_id = generate_html_id(method, "#{position[input]}i")

          field_name = "#{method}(#{position[input]}i)"
          if options[:"discard_#{input}"]
            break if time_inputs.include?(input)

            hidden_value = datetime.respond_to?(input) ? datetime.send(input.to_sym) : datetime
            hidden_fields_capture << template.hidden_field_tag("#{@object_name}[#{field_name}]", (hidden_value || 1), :id => input_id)
          else
            opts = strip_formtastic_options(options).merge(:prefix => @object_name, :field_name => field_name, :default => datetime)
            item_label_text = ::I18n.t(input.to_s, :default => input.to_s.humanize, :scope => [:datetime, :prompts])

            list_items_capture << template.content_tag(:li,
              template.content_tag(:label, item_label_text, :for => input_id) <<
              template.send(:"select_#{input}", datetime, opts, html_options.merge(:id => input_id))
            )
          end
        end

        hidden_fields_capture << field_set_and_list_wrapping_for_method(method, options.merge(:label_for => input_ids.first), list_items_capture)
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
      #     <legend class="label"><label>Authors</label></legend>
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
      # The :label_method option allows you to customize the label for each checkbox two ways:
      #
      # * by naming the correct method to call on each object in the collection as a symbol (:name, :login, etc)
      # * by passing a Proc that will be called on each object in the collection, allowing you to use helpers or multiple model attributes together
      #
      # Examples:
      #
      #   f.input :author, :as => :check_boxes, :label_method => :full_name
      #   f.input :author, :as => :check_boxes, :label_method => :login
      #   f.input :author, :as => :check_boxes, :label_method => :full_name_with_post_count
      #   f.input :author, :as => :check_boxes, :label_method => Proc.new { |a| "#{a.name} (#{pluralize("post", a.posts.count)})" }
      #
      # The :value_method option provides the same customization of the value attribute of each checkbox input tag.
      #
      # Examples:
      #
      #   f.input :author, :as => :check_boxes, :value_method => :full_name
      #   f.input :author, :as => :check_boxes, :value_method => :login
      #   f.input :author, :as => :check_boxes, :value_method => Proc.new { |a| "author_#{a.login}" }
      #
      # You can pre-select/check a specific checkbox value by passing in the :selected option (alias :checked works as well).
      # 
      # Examples:
      #  
      #   f.input :authors, :as => :check_boxes, :selected => @justin
      #   f.input :authors, :as => :check_boxes, :selected => Author.most_popular.collect(&:id)
      #   f.input :authors, :as => :check_boxes, :selected => nil   # override any defaults: select none
      #
      # Finally, you can set :value_as_class => true if you want the li wrapper around each checkbox / label 
      # combination to contain a class with the value of the radio button (useful for applying specific 
      # CSS or Javascript to a particular checkbox).
      #
      def check_boxes_input(method, options)
        collection = find_collection_for_column(method, options)
        html_options = options.delete(:input_html) || {}

        input_name      = generate_association_input_name(method)
        value_as_class  = options.delete(:value_as_class)
        unchecked_value = options.delete(:unchecked_value) || ''
        html_options    = { :name => "#{@object_name}[#{input_name}][]" }.merge(html_options)
        input_ids       = []

        selected_option_is_present = [:selected, :checked].any? { |k| options.key?(k) }
        selected_values = (options.key?(:checked) ? options[:checked] : options[:selected]) if selected_option_is_present
        selected_values  = [*selected_values].compact
        
        list_item_content = collection.map do |c|
          label = c.is_a?(Array) ? c.first : c
          value = c.is_a?(Array) ? c.last : c
          input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
          input_ids << input_id

          html_options[:checked] = selected_values.include?(value) if selected_option_is_present
          html_options[:id] = input_id

          li_content = template.content_tag(:label,
            "#{self.check_box(input_name, html_options, value, unchecked_value)} #{label}",
            :for => input_id
          )

          li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
          template.content_tag(:li, li_content, li_options)
        end

        field_set_and_list_wrapping_for_method(method, options.merge(:label_for => input_ids.first), list_item_content)
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

        self.label(method, options_for_label(options)) <<
        self.country_select(method, priority_countries, strip_formtastic_options(options), html_options)
      end

      # Outputs a label containing a checkbox and the label text. The label defaults
      # to the column name (method name) and can be altered with the :label option.
      # :checked_value and :unchecked_value options are also available.
      #
      # You can pre-select/check the boolean checkbox by passing in the :selected option (alias :checked works as well).
      # 
      # Examples:
      #  
      #   f.input :allow_comments, :as => :boolean, :selected => true   # override any default value: selected/checked
      #
      def boolean_input(method, options)
        html_options = options.delete(:input_html) || {}
        checked = options.key?(:checked) ? options[:checked] : options[:selected]
        html_options[:checked] = checked == true if [:selected, :checked].any? { |k| options.key?(k) }

        input = self.check_box(method, strip_formtastic_options(options).merge(html_options),
                               options.delete(:checked_value) || '1', options.delete(:unchecked_value) || '0')
        options = options_for_label(options)

        # the label() method will insert this nested input into the label at the last minute
        options[:label_prefix_for_nested_input] = input

        self.label(method, options)
      end

      # Generates an input for the given method using the type supplied with :as.
      def inline_input_for(method, options)
        send(:"#{options.delete(:as)}_input", method, options)
      end

      # Generates hints for the given method using the text supplied in :hint.
      #
      def inline_hints_for(method, options) #:nodoc:
        options[:hint] = localized_string(method, options[:hint], :hint)
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

      # Creates an error sentence containing only the first error
      #
      def error_first(errors) #:nodoc:
        template.content_tag(:p, errors.first.untaint, :class => 'inline-errors')
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
      # or the shorter equivalent:
      #
      #   f.inputs 'Task #%i', :for => :tasks
      #
      # And it will generate a fieldset for each task with legend 'Task #1', 'Task #2',
      # 'Task #3' and so on.
      #
      # Note: Special case for the inline inputs (non-block):
      #   f.inputs "My little legend", :title, :body, :author   # Explicit legend string => "My little legend"
      #   f.inputs :my_little_legend, :title, :body, :author    # Localized (118n) legend with I18n key => I18n.t(:my_little_legend, ...)
      #   f.inputs :title, :body, :author                       # First argument is a column => (no legend)
      #
      def field_set_and_list_wrapping(*args, &block) #:nodoc:
        contents = args.last.is_a?(::Hash) ? '' : args.pop.flatten
        html_options = args.extract_options!

        legend  = html_options.delete(:name).to_s
        legend %= parent_child_index(html_options[:parent]) if html_options[:parent]
        legend  = template.content_tag(:legend, template.content_tag(:span, legend)) unless legend.blank?

        if block_given?
          contents = if template.respond_to?(:is_haml?) && template.is_haml?
            template.capture_haml(&block)
          else
            template.capture(&block)
          end
        end

        # Ruby 1.9: String#to_s behavior changed, need to make an explicit join.
        contents = contents.join if contents.respond_to?(:join)
        fieldset = template.content_tag(:fieldset,
          legend << template.content_tag(:ol, contents),
          html_options.except(:builder, :parent)
        )

        template.concat(fieldset) if block_given?
        fieldset
      end

      def field_set_title_from_args(*args) #:nodoc:
        options = args.extract_options!
        options[:name] ||= options.delete(:title)
        title = options[:name]

        if title.blank?
          valid_name_classes = [::String, ::Symbol]
          valid_name_classes.delete(::Symbol) if !block_given? && (args.first.is_a?(::Symbol) && self.content_columns.include?(args.first))
          title = args.shift if valid_name_classes.any? { |valid_name_class| args.first.is_a?(valid_name_class) }
        end
        title = localized_string(title, title, :title) if title.is_a?(::Symbol)
        title
      end

      # Also generates a fieldset and an ordered list but with label based in
      # method. This methods is currently used by radio and datetime inputs.
      #
      def field_set_and_list_wrapping_for_method(method, options, contents) #:nodoc:
        contents = contents.join if contents.respond_to?(:join)

        template.content_tag(:fieldset,
            template.content_tag(:legend,
                self.label(method, options_for_label(options).merge(:for => options.delete(:label_for))), :class => 'label'
              ) <<
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
      def default_input_type(method, options = {}) #:nodoc:
        if column = self.column_for(method)
          # Special cases where the column type doesn't map to an input method.
          case column.type
          when :string
            return :password  if method.to_s =~ /password/
            return :country   if method.to_s =~ /country/
            return :time_zone if method.to_s =~ /time_zone/
          when :integer
            return :select    if method.to_s =~ /_id$/
            return :numeric
          when :float, :decimal
            return :numeric
          when :timestamp
            return :datetime
          end
          
          # Try look for hints in options hash. Quite common senario: Enum keys stored as string in the database.
          return :select    if column.type == :string && options.key?(:collection)
          # Try 3: Assume the input name will be the same as the column type (e.g. string_input).
          return column.type
        else
          if @object
            return :select  if self.reflection_for(method)

            file = @object.send(method) if @object.respond_to?(method)
            return :file    if file && @@file_methods.any? { |m| file.respond_to?(m) }
          end

          return :select    if options.key?(:collection)
          return :password  if method.to_s =~ /password/
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
      def find_collection_for_column(column, options) #:nodoc:
        collection = find_raw_collection_for_column(column, options)

        # Return if we have an Array of strings, fixnums or arrays
        return collection if (collection.instance_of?(Array) || collection.instance_of?(Range)) &&
                             [Array, Fixnum, String, Symbol].include?(collection.first.class)

        label, value = detect_label_and_value_method!(collection, options)
        collection.map { |o| [send_or_call(label, o), send_or_call(value, o)] }
      end

      # As #find_collection_for_column but returns the collection without mapping the label and value
      #
      def find_raw_collection_for_column(column, options) #:nodoc:
        collection = if options[:collection]
          options.delete(:collection)
        elsif reflection = self.reflection_for(column)
          reflection.klass.find(:all, options[:find_options] || {})
        else
          create_boolean_collection(options)
        end

        collection = collection.to_a if collection.is_a?(Hash)
        collection
      end

      # Detects the label and value methods from a collection values set in 
      # @@collection_label_methods. It will use and delete
      # the options :label_method and :value_methods when present
      #
      def detect_label_and_value_method!(collection_or_instance, options = {}) #:nodoc
        label = options.delete(:label_method) || detect_label_method(collection_or_instance)
        value = options.delete(:value_method) || :id
        [label, value]
      end

      # Detected the label collection method when none is supplied using the
      # values set in @@collection_label_methods.
      #
      def detect_label_method(collection) #:nodoc:
        @@collection_label_methods.detect { |m| collection.first.respond_to?(m) }
      end

      # Detects the method to call for fetching group members from the groups when grouping select options
      #
      def detect_group_association(method, group_by)
        object_to_method_reflection = self.reflection_for(method)
        method_class = object_to_method_reflection.klass
        
        method_to_group_association = method_class.reflect_on_association(group_by)
        group_class = method_to_group_association.klass
        
        # This will return in the normal case
        return method.to_s.pluralize.to_sym if group_class.reflect_on_association(method.to_s.pluralize)
      
        # This is for belongs_to associations named differently than their class
        # form.input :parent, :group_by => :customer
        # eg. 
        # class Project
        #   belongs_to :parent, :class_name => 'Project', :foreign_key => 'parent_id'
        #   belongs_to :customer
        # end
        # class Customer
        #   has_many :projects
        # end
        group_method = method_class.to_s.underscore.pluralize.to_sym
        return group_method if group_class.reflect_on_association(group_method) # :projects
        
        # This is for has_many associations named differently than their class
        # eg. 
        # class Project
        #   belongs_to :parent, :class_name => 'Project', :foreign_key => 'parent_id'
        #   belongs_to :customer
        # end
        # class Customer
        #   has_many :tasks, :class_name => 'Project', :foreign_key => 'customer_id'
        # end
        possible_associations =  group_class.reflect_on_all_associations(:has_many).find_all{|assoc| assoc.klass == object_class}
        return possible_associations.first.name.to_sym if possible_associations.count == 1
      
        raise "Cannot infer group association for #{method} grouped by #{group_by}, there were #{possible_associations.empty? ? 'no' : possible_associations.size} possible associations. Please specify using :group_association"
        
      end

      # Returns a hash to be used by radio and select inputs when a boolean field
      # is provided.
      #
      def create_boolean_collection(options) #:nodoc:
        options[:true] ||= ::Formtastic::I18n.t(:yes)
        options[:false] ||= ::Formtastic::I18n.t(:no)
        options[:value_as_class] = true unless options.key?(:value_as_class)

        [ [ options.delete(:true), true], [ options.delete(:false), false ] ]
      end

      # Used by association inputs (select, radio) to generate the name that should
      # be used for the input
      #
      #   belongs_to :author; f.input :author; will generate 'author_id'
      #   belongs_to :entity, :foreign_key = :owner_id; f.input :author; will generate 'owner_id'
      #   has_many :authors; f.input :authors; will generate 'author_ids'
      #   has_and_belongs_to_many will act like has_many
      #
      def generate_association_input_name(method) #:nodoc:
        if reflection = self.reflection_for(method)
          if [:has_and_belongs_to_many, :has_many].include?(reflection.macro)
            "#{method.to_s.singularize}_ids"
          else
            reflection.options[:foreign_key] || "#{method}_id"
          end
        else
          method
        end.to_sym
      end

      # If an association method is passed in (f.input :author) try to find the
      # reflection object.
      #
      def reflection_for(method) #:nodoc:
        @object.class.reflect_on_association(method) if @object.class.respond_to?(:reflect_on_association)
      end

      # Get a column object for a specified attribute method - if possible.
      #
      def column_for(method) #:nodoc:
        @object.column_for_attribute(method) if @object.respond_to?(:column_for_attribute)
      end

      # Generates default_string_options by retrieving column information from
      # the database.
      #
      def default_string_options(method, type) #:nodoc:
        column = self.column_for(method)

        if type == :numeric || column.nil? || column.limit.nil?
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
      def generate_html_id(method_name, value='input') #:nodoc:
        if options.has_key?(:index)
          index = "_#{options[:index]}"
        elsif defined?(@auto_index)
          index = "_#{@auto_index}"
        else
          index = ""
        end
        sanitized_method_name = method_name.to_s.gsub(/[\?\/\-]$/, '')

        "#{sanitized_object_name}#{index}_#{sanitized_method_name}_#{value}"
      end

      # Gets the nested_child_index value from the parent builder. In Rails 2.3
      # it always returns a fixnum. In next versions it returns a hash with each
      # association that the parent builds.
      #
      def parent_child_index(parent) #:nodoc:
        duck = parent[:builder].instance_variable_get('@nested_child_index')

        if duck.is_a?(Hash)
          child = parent[:for]
          child = child.first if child.respond_to?(:first)
          duck[child].to_i + 1
        else
          duck.to_i + 1
        end
      end

      def sanitized_object_name #:nodoc:
        @sanitized_object_name ||= @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
      end

      def humanized_attribute_name(method) #:nodoc:
        method.to_s.send(@@label_str_method)
      end

      # Internal generic method for looking up localized values within Formtastic
      # using I18n, if no explicit value is set and I18n-lookups are enabled.
      # 
      # Enabled/Disable this by setting:
      #
      #   Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true/false
      #
      # Lookup priority:
      #
      #   'formtastic.{{type}}.{{model}}.{{action}}.{{attribute}}'
      #   'formtastic.{{type}}.{{model}}.{{attribute}}'
      #   'formtastic.{{type}}.{{attribute}}'
      # 
      # Example:
      #   
      #   'formtastic.labels.post.edit.title'
      #   'formtastic.labels.post.title'
      #   'formtastic.labels.title'
      # 
      # NOTE: Generic, but only used for form input titles/labels/hints/actions (titles = legends, actions = buttons).
      #
      def localized_string(key, value, type, options = {}) #:nodoc:
        key = value if value.is_a?(::Symbol)

        if value.is_a?(::String)
          value
        else
          use_i18n = value.nil? ? @@i18n_lookups_by_default : (value != false)

          if use_i18n
            model_name  = self.model_name.underscore
            action_name = template.params[:action].to_s rescue ''
            attribute_name = key.to_s

            defaults = ::Formtastic::I18n::SCOPES.collect do |i18n_scope|
              i18n_path = i18n_scope.dup
              i18n_path.gsub!('{{action}}', action_name)
              i18n_path.gsub!('{{model}}', model_name)
              i18n_path.gsub!('{{attribute}}', attribute_name)
              i18n_path.gsub!('..', '.')
              i18n_path.to_sym
            end
            defaults << ''

            i18n_value = ::Formtastic::I18n.t(defaults.shift,
              options.merge(:default => defaults, :scope => type.to_s.pluralize.to_sym))
            i18n_value.blank? ? nil : i18n_value
          end
        end
      end

      def model_name
        @object.present? ? @object.class.name : @object_name.to_s.classify
      end

      def send_or_call(duck, object)
        if duck.is_a?(Proc)
          duck.call(object)
        else
          object.send(duck)
        end
      end

      def set_include_blank(options)
        unless options.key?(:include_blank) || options.key?(:prompt)
          options[:include_blank] = @@include_blank_for_select_by_default
        end
        options
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
  # object is given as an argument, but the generic style is also supported, as are forms with 
  # inline objects (Post.new) rather than objects with instance variables (@post):
  #
  #   <% semantic_form_for :post, @post, :url => posts_path do |f| %>
  #     ...
  #   <% end %>
  #
  #   <% semantic_form_for :post, Post.new, :url => posts_path do |f| %>
  #     ...
  #   <% end %>
  module SemanticFormHelper
    @@builder = ::Formtastic::SemanticFormBuilder
    mattr_accessor :builder
    
    @@default_field_error_proc = nil
    
    # Override the default ActiveRecordHelper behaviour of wrapping the input.
    # This gets taken care of semantically by adding an error class to the LI tag
    # containing the input.
    #
    FIELD_ERROR_PROC = proc do |html_tag, instance_tag|
      html_tag
    end
    
    def with_custom_field_error_proc(&block)
      @@default_field_error_proc = ::ActionView::Base.field_error_proc
      ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
      result = yield
      ::ActionView::Base.field_error_proc = @@default_field_error_proc
      result
    end
    
    [:form_for, :fields_for, :remote_form_for].each do |meth|
      src = <<-END_SRC
        def semantic_#{meth}(record_or_name_or_array, *args, &proc)
          options = args.extract_options!
          options[:builder] ||= @@builder
          options[:html] ||= {}
          
          class_names = options[:html][:class] ? options[:html][:class].split(" ") : []
          class_names << "formtastic"
          class_names << case record_or_name_or_array
            when String, Symbol then record_or_name_or_array.to_s               # :post => "post"
            when Array then record_or_name_or_array.last.class.to_s.underscore  # [@post, @comment] # => "comment"
            else record_or_name_or_array.class.to_s.underscore                  # @post => "post"
          end
          options[:html][:class] = class_names.join(" ")
          
          with_custom_field_error_proc do
            #{meth}(record_or_name_or_array, *(args << options), &proc)
          end
        end
      END_SRC
      module_eval src, __FILE__, __LINE__
    end
    alias :semantic_form_remote_for :semantic_remote_form_for
    
  end
end
