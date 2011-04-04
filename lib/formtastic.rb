# encoding: utf-8
require File.join(File.dirname(__FILE__), *%w[formtastic i18n])
require File.join(File.dirname(__FILE__), *%w[formtastic util])
require File.join(File.dirname(__FILE__), *%w[formtastic railtie]) if defined?(::Rails::Railtie)

module Formtastic #:nodoc:

  class SemanticFormBuilder < ActionView::Helpers::FormBuilder
    
    configurables = [
      :default_text_field_size, :default_text_area_height, :default_text_area_width, :all_fields_required_by_default, :include_blank_for_select_by_default,
      :required_string, :optional_string, :inline_errors, :label_str_method, :collection_value_methods, :collection_label_methods, :file_metadata_suffixes,
      :inline_order, :custom_inline_order, :file_methods, :priority_countries, :i18n_lookups_by_default, :escape_html_entities_in_hints_and_labels,
      :default_commit_button_accesskey, :default_inline_error_class, :default_hint_class, :default_error_list_class
    ]
    
    if respond_to?(:class_attribute)
      class_attribute *configurables
    else
      class_inheritable_accessor *configurables
    end
    
    cattr_accessor :custom_namespace

    self.default_text_field_size = nil
    self.default_text_area_height = 20
    self.default_text_area_width = nil
    self.all_fields_required_by_default = true
    self.include_blank_for_select_by_default = true
    self.required_string = proc { ::Formtastic::Util.html_safe(%{<abbr title="#{::Formtastic::I18n.t(:required)}">*</abbr>}) }
    self.optional_string = ''
    self.inline_errors = :sentence
    self.label_str_method = :humanize
    self.collection_label_methods = %w[to_label display_name full_name name title username login value to_s]
    self.collection_value_methods = %w[id to_s]
    self.inline_order = [ :input, :hints, :errors ]
    self.custom_inline_order = {}
    self.file_methods = [ :file?, :public_filename, :filename ]
    self.file_metadata_suffixes = ['content_type', 'file_name', 'file_size']
    self.priority_countries = ["Australia", "Canada", "United Kingdom", "United States"]
    self.i18n_lookups_by_default = false
    self.escape_html_entities_in_hints_and_labels = true
    self.default_commit_button_accesskey = nil
    self.default_inline_error_class = 'inline-errors'
    self.default_error_list_class = 'errors'
    self.default_hint_class = 'inline-hints'

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
    # * :email (an email input) - default for :string column types with 'email' as the method name.
    # * :url (a url input) - default for :string column types with 'url' as the method name.
    # * :phone (a tel input) - default for :string column types with 'phone' or 'fax' in the method name.
    # * :search (a search input) - default for :string column types with 'search' as the method name.
    # * :country (a select menu of country names) - requires a country_select plugin to be installed
    # * :email (an email input) - New in HTML5 - needs to be explicitly provided with :as => :email
    # * :url (a url input) - New in HTML5 - needs to be explicitly provided with :as => :url
    # * :phone (a tel input) - New in HTML5 - needs to be explicitly provided with :as => :phone
    # * :search (a search input) - New in HTML5 - needs to be explicity provided with :as => :search
    # * :country (a select menu of country names) - requires a country_select plugin to be installed
    # * :hidden (a hidden field) - creates a hidden field (added for compatibility)
    #
    # Example:
    #
    #   <% semantic_form_for @employee do |form| %>
    #     <% form.inputs do -%>
    #       <%= form.input :name, :label => "Full Name" %>
    #       <%= form.input :manager, :as => :radio %>
    #       <%= form.input :secret, :as => :password, :input_html => { :value => "xxxx" } %>
    #       <%= form.input :hired_at, :as => :date, :label => "Date Hired" %>
    #       <%= form.input :phone, :required => false, :hint => "Eg: +1 555 1234" %>
    #       <%= form.input :email %>
    #       <%= form.input :website, :as => :url, :hint => "You may wish to omit the http://" %>
    #     <% end %>
    #   <% end %>
    #
    def input(method, options = {})
      options = options.dup # Allow options to be shared without being tainted by Formtastic
      
      options[:required] = method_required?(method) unless options.key?(:required)
      options[:as]     ||= default_input_type(method, options)

      html_class = [ options[:as], (options[:required] ? :required : :optional) ]
      html_class << 'error' if has_errors?(method, options)

      wrapper_html = options.delete(:wrapper_html) || {}
      wrapper_html[:id]  ||= generate_html_id(method)
      wrapper_html[:class] = (html_class << wrapper_html[:class]).flatten.compact.join(' ')

      if options[:input_html] && options[:input_html][:id]
        options[:label_html] ||= {}
        options[:label_html][:for] ||= options[:input_html][:id]
      end

      input_parts = (custom_inline_order[options[:as]] || inline_order).dup
      input_parts = input_parts - [:errors, :hints] if options[:as] == :hidden

      list_item_content = input_parts.map do |type|
        send(:"inline_#{type}_for", method, options)
      end.compact.join("\n")

      return template.content_tag(:li, Formtastic::Util.html_safe(list_item_content), wrapper_html)
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
          args  = association_columns(:belongs_to)
          args += content_columns
          args -= RESERVED_COLUMNS
          args.compact!
        end
        legend = args.shift if args.first.is_a?(::String)
        contents = args.collect { |method| input(method.to_sym) }
        args.unshift(legend) if legend.present?

        field_set_and_list_wrapping(*((args << html_options) << contents))
      end
    end

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
    #  <%= form.commit_button :button_html => { :class => "pretty" } %> => <input name="commit" type="submit" value="Save Post" class="pretty {create|update|submit}" />
    def commit_button(*args)
      options = args.extract_options!
      text = options.delete(:label) || args.shift

      if @object && (@object.respond_to?(:persisted?) || @object.respond_to?(:new_record?))
        if @object.respond_to?(:persisted?) # ActiveModel
          key = @object.persisted? ? :update : :create
        else # Rails 2
          key = @object.new_record? ? :create : :update
        end

        # Deal with some complications with ActiveRecord::Base.human_name and two name models (eg UserPost)
        # ActiveRecord::Base.human_name falls back to ActiveRecord::Base.name.humanize ("Userpost")
        # if there's no i18n, which is pretty crappy.  In this circumstance we want to detect this
        # fall back (human_name == name.humanize) and do our own thing name.underscore.humanize ("User Post")
        if @object.class.model_name.respond_to?(:human)
          object_name = @object.class.model_name.human
        else
          object_human_name = @object.class.human_name                # default is UserPost => "Userpost", but i18n may do better ("User post")
          crappy_human_name = @object.class.name.humanize             # UserPost => "Userpost"
          decent_human_name = @object.class.name.underscore.humanize  # UserPost => "User post"
          object_name = (object_human_name == crappy_human_name) ? decent_human_name : object_human_name
        end
      else
        key = :submit
        object_name = @object_name.to_s.send(label_str_method)
      end

      text = (localized_string(key, text, :action, :model => object_name) ||
              ::Formtastic::I18n.t(key, :model => object_name)) unless text.is_a?(::String)

      button_html = options.delete(:button_html) || {}
      button_html.merge!(:class => [button_html[:class], key].compact.join(' '))

      wrapper_html_class = ['commit'] # TODO: Add class reflecting on form action.
      wrapper_html = options.delete(:wrapper_html) || {}
      wrapper_html[:class] = (wrapper_html_class << wrapper_html[:class]).flatten.compact.join(' ')

      accesskey = (options.delete(:accesskey) || default_commit_button_accesskey) unless button_html.has_key?(:accesskey)
      button_html = button_html.merge(:accesskey => accesskey) if accesskey
      template.content_tag(:li, Formtastic::Util.html_safe(submit(text, button_html)), wrapper_html)
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
      opts[:builder] ||= self.class
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
      text = Formtastic::Util.html_safe(text)

      # special case for boolean (checkbox) labels, which have a nested input
      if options.key?(:label_prefix_for_nested_input)
        text = options.delete(:label_prefix_for_nested_input) + text
      end

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
    def inline_errors_for(method, options = {}) #:nodoc:
      if render_inline_errors?
        errors = error_keys(method, options).map{|x| @object.errors[x] }.flatten.compact.uniq
        send(:"error_#{inline_errors}", [*errors], options) if errors.any?
      else
        nil
      end
    end
    alias :errors_on :inline_errors_for

    # Generates error messages for given method names and for base.
    # You can pass a hash with html options that will be added to ul tag
    #
    # == Examples
    #
    #  f.semantic_errors # This will show only errors on base
    #  f.semantic_errors :state # This will show errors on base and state
    #  f.semantic_errors :state, :class => "awesome" # errors will be rendered in ul.awesome
    #
    def semantic_errors(*args)
      html_options = args.extract_options!
      full_errors = args.inject([]) do |array, method|
        attribute = localized_string(method, method.to_sym, :label) || humanized_attribute_name(method)
        errors = Array(@object.errors[method.to_sym]).to_sentence
        errors.present? ? array << [attribute, errors].join(" ") : array ||= []
      end
      full_errors << @object.errors[:base]
      full_errors.flatten!
      full_errors.compact!
      return nil if full_errors.blank?
      html_options[:class] ||= "errors"
      template.content_tag(:ul, html_options) do
        Formtastic::Util.html_safe(full_errors.map { |error| template.content_tag(:li, Formtastic::Util.html_safe(error)) }.join)
      end
    end

    protected

      def error_keys(method, options)
        @methods_for_error ||= {}
        @methods_for_error[method] ||= begin
          methods_for_error = [method.to_sym]
          methods_for_error << file_metadata_suffixes.map{|suffix| "#{method}_#{suffix}".to_sym} if is_file?(method, options)
          methods_for_error << [association_primary_key(method)] if association_macro_for_method(method) == :belongs_to
          methods_for_error.flatten.compact.uniq
        end
      end

      def has_errors?(method, options)
        methods_for_error = error_keys(method,options)
        @object && @object.respond_to?(:errors) && methods_for_error.any?{|error| !@object.errors[error].blank?}
      end

      def render_inline_errors?
        @object && @object.respond_to?(:errors) && INLINE_ERROR_TYPES.include?(inline_errors)
      end

      # Collects content columns (non-relation columns) for the current form object class.
      #
      def content_columns #:nodoc:
        model_name.constantize.content_columns.collect { |c| c.name.to_sym }.compact rescue []
      end

      # Collects association columns (relation columns) for the current form object class.
      #
      def association_columns(*by_associations) #:nodoc:
        if @object.present? && @object.class.respond_to?(:reflections)
          @object.class.reflections.collect do |name, association_reflection|
            if by_associations.present?
              name if by_associations.include?(association_reflection.macro)
            else
              name
            end
          end.compact
        else
          []
        end
      end

      # Returns nil, or a symbol like :belongs_to or :has_many
      def association_macro_for_method(method) #:nodoc:
        reflection = reflection_for(method)
        reflection.macro if reflection
      end

      def association_primary_key(method)
        reflection = reflection_for(method)
        reflection.options[:foreign_key] if reflection && !reflection.options[:foreign_key].blank?
        :"#{method}_id"
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
          lambda do |f|
            contents = f.inputs(*args){ block.call(f) }
            template.concat(contents) if ::Formtastic::Util.rails3?
            contents
          end
        else
          lambda do |f|
            contents = f.inputs(*args)
            template.concat(contents) if ::Formtastic::Util.rails3?
            contents
          end
        end

        fields_for_args = [options.delete(:for), options.delete(:for_options) || {}].flatten
        semantic_fields_for(*fields_for_args, &fields_for_block)
      end

      # Remove any Formtastic-specific options before passing the down options.
      #
      def strip_formtastic_options(options) #:nodoc:
        options.except(:value_method, :label_method, :collection, :required, :label,
                       :as, :hint, :input_html, :label_html, :value_as_class, :find_options, :class)
      end

      # Determins if the attribute (eg :title) should be considered required or not.
      #
      # * if the :required option was provided in the options hash, the true/false value will be
      #   returned immediately, allowing the view to override any guesswork that follows:
      #
      # * if the :required option isn't provided in the options hash, and the ValidationReflection
      #   plugin is installed (http://github.com/redinger/validation_reflection), or the object is
      #   an ActiveModel, true is returned
      #   if the validates_presence_of macro has been used in the class for this attribute, or false
      #   otherwise.
      #
      # * if the :required option isn't provided, and validates_presence_of can't be determined, the
      #   configuration option all_fields_required_by_default is used.
      #
      def method_required?(attribute) #:nodoc:
        attribute_sym = attribute.to_s.sub(/_id$/, '').to_sym

        if @object && @object.class.respond_to?(:reflect_on_validations_for)
          @object.class.reflect_on_validations_for(attribute_sym).any? do |validation|
            (validation.macro == :validates_presence_of || validation.macro == :validates_inclusion_of) &&
            validation.name == attribute_sym &&
            (validation.options.present? ? options_require_validation?(validation.options) : true)
          end
        else
          if @object && @object.class.respond_to?(:validators_on)
            !@object.class.validators_on(attribute_sym).find{|validator| (validator.kind == :presence || validator.kind == :inclusion) && (validator.options.present? ? options_require_validation?(validator.options) : true)}.nil?
          else
            all_fields_required_by_default
          end
        end
      end

      # Determines whether the given options evaluate to true
      def options_require_validation?(options) #nodoc
        allow_blank = options[:allow_blank]
        return !allow_blank unless allow_blank.nil?
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
        html_options = default_string_options(method, type).merge(html_options) if [:numeric, :string, :password, :text, :phone, :search, :url, :email].include?(type)
        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]
        label(method, label_options) <<
          send(respond_to?(form_helper_method) ? form_helper_method : :text_field, method, html_options)
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

      # Outputs a label and a standard Rails email field inside the wrapper.
      def email_input(method, options)
        basic_input_helper(:email_field, :email, method, options)
      end

      # Outputs a label and a standard Rails phone field inside the wrapper.
      def phone_input(method, options)
        basic_input_helper(:phone_field, :phone, method, options)
      end

      # Outputs a label and a standard Rails url field inside the wrapper.
      def url_input(method, options)
        basic_input_helper(:url_field, :url, method, options)
      end

      # Outputs a label and a standard Rails search field inside the wrapper.
      def search_input(method, options)
        basic_input_helper(:search_field, :search, method, options)
      end

      # Outputs a hidden field inside the wrapper, which should be hidden with CSS.
      # Additionals options can be given using :input_hml. Should :input_html not be
      # specified every option except for formtastic options will be sent straight
      # to hidden input element.
      #
      def hidden_input(method, options)
        options ||= {}
        html_options = options.delete(:input_html) || strip_formtastic_options(options)
        html_options[:id] ||= generate_html_id(method, "")
        hidden_field(method, html_options)
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
      # You can customize the options available in the select by passing in a collection. A collection can be given
      # as an Array, a Hash or as a String (containing pre-rendered HTML options). If not provided, the choices are
      # found by inferring the parent's class name from the method name and simply calling all on it
      # (VehicleOwner.all in the example above).
      #
      # Examples:
      #
      #   f.input :author, :collection => @authors
      #   f.input :author, :collection => Author.all
      #   f.input :author, :collection => [@justin, @kate]
      #   f.input :author, :collection => {@justin.name => @justin.id, @kate.name => @kate.id}
      #   f.input :author, :collection => ["Justin", "Kate", "Amelia", "Gus", "Meg"]
      #   f.input :author, :collection => grouped_options_for_select(["North America",[["United States","US"],["Canada","CA"]]])
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
        html_options[:multiple] = html_options[:multiple] || options.delete(:multiple)
        html_options.delete(:multiple) if html_options[:multiple].nil?

        reflection = reflection_for(method)
        if reflection && [ :has_many, :has_and_belongs_to_many ].include?(reflection.macro)
          html_options[:multiple] = true if html_options[:multiple].nil?
          html_options[:size]     ||= 5
          options[:include_blank] ||= false
        end
        options = set_include_blank(options)
        input_name = generate_association_input_name(method)
        html_options[:id] ||= generate_html_id(input_name, "")

        select_html = if options[:group_by]
          # The grouped_options_select is a bit counter intuitive and not optimised (mostly due to ActiveRecord).
          # The formtastic user however shouldn't notice this too much.
          raw_collection = find_raw_collection_for_column(method, options.reverse_merge(:find_options => { :include => options[:group_by] }))
          label, value = detect_label_and_value_method!(raw_collection, options)
          group_collection = raw_collection.map { |option| option.send(options[:group_by]) }.uniq
          group_label_method = options[:group_label_method] || detect_label_method(group_collection)
          group_collection = group_collection.sort_by { |group_item| group_item.send(group_label_method) }
          group_association = options[:group_association] || detect_group_association(method, options[:group_by])

          # Here comes the monster with 8 arguments
          grouped_collection_select(input_name, group_collection,
                                         group_association, group_label_method,
                                         value, label,
                                         strip_formtastic_options(options), html_options)
        else
          collection = find_collection_for_column(method, options)

          select(input_name, collection, strip_formtastic_options(options), html_options)
        end

        label_options = options_for_label(options).merge(:input_name => input_name)
        label_options[:for] ||= html_options[:id]
        label(method, label_options) << select_html
      end

      # Outputs a timezone select input as Rails' time_zone_select helper. You
      # can give priority zones as option.
      #
      # Examples:
      #
      #   f.input :time_zone, :as => :time_zone, :priority_zones => /Australia/
      def time_zone_input(method, options)
        html_options = options.delete(:input_html) || {}
        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]
        label(method, label_options) <<
        time_zone_select(method, options.delete(:priority_zones),
          strip_formtastic_options(options), html_options)
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
      # (Author.all in the example above).
      #
      # Examples:
      #
      #   f.input :author, :as => :radio, :collection => @authors
      #   f.input :author, :as => :radio, :collection => Author.all
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
      # Finally, you can set :value_as_class => true if you want the li wrapper around each radio
      # button / label combination to contain a class with the value of the radio button (useful for
      # applying specific CSS or Javascript to a particular radio button).
      def radio_input(method, options)
        collection   = find_collection_for_column(method, options)
        html_options = strip_formtastic_options(options).merge(options.delete(:input_html) || {})

        input_name = generate_association_input_name(method)
        value_as_class = options.delete(:value_as_class)
        input_ids = []

        list_item_content = collection.map do |c|
          label = c.is_a?(Array) ? c.first : c
          value = c.is_a?(Array) ? c.last  : c
          input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
          input_ids << input_id

          html_options[:id] = input_id

          li_content = template.content_tag(:label,
            Formtastic::Util.html_safe("#{radio_button(input_name, value, html_options)} #{escape_html_entities(label)}"),
            :for => input_id
          )

          li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
          template.content_tag(:li, Formtastic::Util.html_safe(li_content), li_options)
        end

        template.content_tag(:fieldset,
          legend_tag(method, options) << template.content_tag(:ol, Formtastic::Util.html_safe(list_item_content.join))
        )
      end

      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the date (year, month, day).  Each li contains a label
      # (eg "Year") and a select box. Overwriting the label is possible by adding the :labels option.
      # :labels should be a hash with the field (e.g. day) as key and the label text as value.
      # See date_or_datetime_input for a more detailed output example.
      #
      # Some of Rails' options for select_date are supported, but not everything yet, see
      # documentation of date_or_datetime_input() for more information.
      def date_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options.merge(:discard_hour => true))
      end

      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the date (year, month, day, hour, min, sec).  Each li
      # contains a label (eg "Year") and a select box. Overwriting the label is possible by adding
      # the :labels option. :labels should be a hash with the field (e.g. day) as key and the label
      # text as value.  See date_or_datetime_input for a more detailed output example.
      #
      # Some of Rails' options for select_date are supported, but not everything yet, see
      # documentation of date_or_datetime_input() for more information.
      def datetime_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options)
      end

      # Outputs a fieldset with a legend for the method label, and a ordered list (ol) of list
      # items (li), one for each fragment for the time (hour, minute, second).  Each li contains a label
      # (eg "Hour") and a select box. Overwriting the label is possible by adding the :labels option.
      # :labels should be a hash with the field (e.g. day) as key and the label text as value.
      # See date_or_datetime_input for a more detailed output example.
      #
      # Some of Rails' options for select_time are supported, but not everything yet, see
      # documentation of date_or_datetime_input() for more information.
      def time_input(method, options)
        options = set_include_blank(options)
        date_or_datetime_input(method, options.merge(:discard_year => true, :discard_month => true, :discard_day => true))
      end

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
      # by inferring the parent's class name from the method name and simply calling all on
      # it (Author.all in the example above).
      #
      # Examples:
      #
      #   f.input :author, :as => :check_boxes, :collection => @authors
      #   f.input :author, :as => :check_boxes, :collection => Author.all
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
      # Formtastic works around a bug in rails handling of check box collections by
      # not generating the hidden fields for state checking of the checkboxes
      # The :hidden_fields option provides a way to re-enable these hidden inputs by
      # setting it to true.
      #
      #   f.input :authors, :as => :check_boxes, :hidden_fields => false
      #   f.input :authors, :as => :check_boxes, :hidden_fields => true
      #
      # Finally, you can set :value_as_class => true if you want the li wrapper around each checkbox / label
      # combination to contain a class with the value of the radio button (useful for applying specific
      # CSS or Javascript to a particular checkbox).
      #
      def check_boxes_input(method, options)
        collection = find_collection_for_column(method, options)
        html_options = options.delete(:input_html) || {}

        input_name      = generate_association_input_name(method)
        hidden_fields   = options.delete(:hidden_fields)
        value_as_class  = options.delete(:value_as_class)
        unchecked_value = options.delete(:unchecked_value) || ''
        html_options    = { :name => "#{@object_name}[#{input_name}][]" }.merge(html_options)
        input_ids       = []

        selected_values = find_selected_values_for_column(method, options)
        disabled_option_is_present = options.key?(:disabled)
        disabled_values = [*options[:disabled]] if disabled_option_is_present

        li_options = value_as_class ? { :class => [method.to_s.singularize, 'default'].join('_') } : {}

        list_item_content = collection.map do |c|
          label = c.is_a?(Array) ? c.first : c
          value = c.is_a?(Array) ? c.last : c
          input_id = generate_html_id(input_name, value.to_s.gsub(/\s/, '_').gsub(/\W/, '').downcase)
          input_ids << input_id

          html_options[:checked] = selected_values.include?(value)
          html_options[:disabled] = disabled_values.include?(value) if disabled_option_is_present
          html_options[:id] = input_id

          li_content = template.content_tag(:label,
            Formtastic::Util.html_safe("#{create_check_boxes(input_name, html_options, value, unchecked_value, hidden_fields)} #{escape_html_entities(label)}"),
            :for => input_id
          )

          li_options = value_as_class ? { :class => [method.to_s.singularize, value.to_s.downcase].join('_') } : {}
          template.content_tag(:li, Formtastic::Util.html_safe(li_content), li_options)
        end

        fieldset_content = legend_tag(method, options)
        fieldset_content << create_hidden_field_for_check_boxes(input_name, value_as_class) unless hidden_fields
        fieldset_content << template.content_tag(:ol, Formtastic::Util.html_safe(list_item_content.join))
        template.content_tag(:fieldset, fieldset_content)
      end

      # Used by check_boxes input. The selected values will be set by retrieving the value
      # through the association.
      #
      # If the collection is not a hash or an array of strings, fixnums or symbols,
      # we use value_method to retrieve an array with the values
      def find_selected_values_for_column(method, options)
        if object.respond_to?(method)
          collection = [object.send(method)].compact.flatten
          label, value = detect_label_and_value_method!(collection, options)
          [*collection.map { |o| send_or_call(value, o) }].compact
        else
          []
        end
      end

      # Outputs a custom hidden field for check_boxes
      def create_hidden_field_for_check_boxes(method, value_as_class) #:nodoc:
        options = value_as_class ? { :class => [method.to_s.singularize, 'default'].join('_') } : {}
        input_name = "#{object_name}[#{method.to_s}][]"
        template.hidden_field_tag(input_name, '', options)
      end

      # Outputs a checkbox tag. If called with no_hidden_input = true a plain check_box_tag is returned,
      # otherwise the helper uses the output generated by the rails check_box method.
      def create_check_boxes(input_name, html_options = {}, checked_value = "1", unchecked_value = "0", hidden_fields = false) #:nodoc:
        return template.check_box_tag(input_name, checked_value, html_options[:checked], html_options) unless hidden_fields == true
        check_box(input_name, html_options, checked_value, unchecked_value)
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
        raise "To use the :country input, please install a country_select plugin, like this one: http://github.com/rails/iso-3166-country-select" unless respond_to?(:country_select)

        html_options = options.delete(:input_html) || {}
        priority_countries = options.delete(:priority_countries) || self.priority_countries

        field_id = generate_html_id(method, "")
        html_options[:id] ||= field_id
        label_options = options_for_label(options)
        label_options[:for] ||= html_options[:id]

        label(method, label_options) <<
        country_select(method, priority_countries, strip_formtastic_options(options), html_options)
      end

      # Outputs a label containing a checkbox and the label text. The label defaults
      # to the column name (method name) and can be altered with the :label option.
      # :checked_value and :unchecked_value options are also available.
      def boolean_input(method, options)
        html_options  = options.delete(:input_html) || {}
        checked_value = options.delete(:checked_value) || '1'
        unchecked_value = options.delete(:unchecked_value) || '0'
        checked = @object && ActionView::Helpers::InstanceTag.check_box_checked?(@object.send(:"#{method}"), checked_value)

        html_options[:id] = html_options[:id] || generate_html_id(method, "")
        input = template.check_box_tag(
          "#{@object_name}[#{method}]",
          checked_value,
          checked,
          html_options
        )
        
        options = options_for_label(options)
        options[:for] ||= html_options[:id]

        # the label() method will insert this nested input into the label at the last minute
        options[:label_prefix_for_nested_input] = input

        template.hidden_field_tag((html_options[:name] || "#{@object_name}[#{method}]"), unchecked_value, :id => nil, :disabled => html_options[:disabled]) << label(method, options)
      end

      # Generates an input for the given method using the type supplied with :as.
      def inline_input_for(method, options)
        send(:"#{options.delete(:as)}_input", method, options)
      end

      # Generates hints for the given method using the text supplied in :hint.
      #
      def inline_hints_for(method, options) #:nodoc:
        options[:hint] = localized_string(method, options[:hint], :hint)
        return if options[:hint].blank? or options[:hint].kind_of? Hash
        hint_class = options[:hint_class] || default_hint_class
        template.content_tag(:p, Formtastic::Util.html_safe(options[:hint]), :class => hint_class)
      end

      # Creates an error sentence by calling to_sentence on the errors array.
      #
      def error_sentence(errors, options = {}) #:nodoc:
        error_class = options[:error_class] || default_inline_error_class
        template.content_tag(:p, Formtastic::Util.html_safe(errors.to_sentence.untaint), :class => error_class)
      end

      # Creates an error li list.
      #
      def error_list(errors, options = {}) #:nodoc:
        error_class = options[:error_class] || default_error_list_class
        list_elements = []
        errors.each do |error|
          list_elements <<  template.content_tag(:li, Formtastic::Util.html_safe(error.untaint))
        end
        template.content_tag(:ul, Formtastic::Util.html_safe(list_elements.join("\n")), :class => error_class)
      end

      # Creates an error sentence containing only the first error
      #
      def error_first(errors, options = {}) #:nodoc:
        error_class = options[:error_class] || default_inline_error_class
        template.content_tag(:p, Formtastic::Util.html_safe(errors.first.untaint), :class => error_class)
      end

      # Generates the required or optional string. If the value set is a proc,
      # it evaluates the proc first.
      #
      def required_or_optional_string(required) #:nodoc:
        string_or_proc = case required
          when true
            required_string
          when false
            optional_string
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

        legend  = html_options.dup.delete(:name).to_s
        legend %= parent_child_index(html_options[:parent]) if html_options[:parent]
        legend  = template.content_tag(:legend, template.content_tag(:span, Formtastic::Util.html_safe(legend))) unless legend.blank?

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
          Formtastic::Util.html_safe(legend) << template.content_tag(:ol, Formtastic::Util.html_safe(contents)),
          html_options.except(:builder, :parent)
        )

        template.concat(fieldset) if block_given? && !Formtastic::Util.rails3?
        fieldset
      end

      def field_set_title_from_args(*args) #:nodoc:
        options = args.extract_options!
        options[:name] ||= options.delete(:title)
        title = options[:name]

        if title.blank?
          valid_name_classes = [::String, ::Symbol]
          valid_name_classes.delete(::Symbol) if !block_given? && (args.first.is_a?(::Symbol) && content_columns.include?(args.first))
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
                label(method, options_for_label(options).merge(:for => options.delete(:label_for))), :class => 'label'
              ) <<
            template.content_tag(:ol, Formtastic::Util.html_safe(contents))
          )
      end

      # Generates the legend for radiobuttons and checkboxes
      def legend_tag(method, options = {})
        if options[:label] == false
          Formtastic::Util.html_safe("")
        else
          text = localized_string(method, options[:label], :label) || humanized_attribute_name(method)
          text += required_or_optional_string(options.delete(:required))
          text = Formtastic::Util.html_safe(text)
          template.content_tag :legend, template.label_tag(nil, text, :for => nil), :class => :label
        end
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
        if column = column_for(method)
          # Special cases where the column type doesn't map to an input method.
          case column.type
          when :string
            return :password  if method.to_s =~ /password/
            return :country   if method.to_s =~ /country$/
            return :time_zone if method.to_s =~ /time_zone/
            return :email     if method.to_s =~ /email/
            return :url       if method.to_s =~ /^url$|^website$|_url$/
            return :phone     if method.to_s =~ /(phone|fax)/
            return :search    if method.to_s =~ /^search$/
          when :integer
            return :select    if reflection_for(method)
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
            return :select  if reflection_for(method)

            return :file    if is_file?(method, options)
          end

          return :select    if options.key?(:collection)
          return :password  if method.to_s =~ /password/
          return :string
        end
      end

      def is_file?(method, options = {})
        @files ||= {}
        @files[method] ||= (options[:as].present? && options[:as] == :file) || begin
          file = @object.send(method) if @object && @object.respond_to?(method)
          file && file_methods.any?{|m| file.respond_to?(m)}
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

        # Return if we have a plain string
        return collection if collection.instance_of?(String) || collection.instance_of?(::Formtastic::Util.rails_safe_buffer_class)

        # Return if we have an Array of strings, fixnums or arrays
        return collection if (collection.instance_of?(Array) || collection.instance_of?(Range)) &&
                             [Array, Fixnum, String, Symbol].include?(collection.first.class) &&
                             !(options.include?(:label_method) || options.include?(:value_method))

        label, value = detect_label_and_value_method!(collection, options)
        collection.map { |o| [send_or_call(label, o), send_or_call(value, o)] }
      end

      # As #find_collection_for_column but returns the collection without mapping the label and value
      #
      def find_raw_collection_for_column(column, options) #:nodoc:
        collection = if options[:collection]
          options.delete(:collection)
        elsif reflection = reflection_for(column)
          options[:find_options] ||= {}

          if conditions = reflection.options[:conditions]
            if reflection.klass.respond_to?(:merge_conditions)
              options[:find_options][:conditions] = reflection.klass.merge_conditions(conditions, options[:find_options][:conditions])
              reflection.klass.all(options[:find_options])
            else
              reflection.klass.where(conditions).where(options[:find_options][:conditions])
            end
          else
            reflection.klass.all(options[:find_options])
          end
        else
          create_boolean_collection(options)
        end

        collection = collection.to_a if collection.is_a?(Hash)
        collection
      end

      # Detects the label and value methods from a collection using methods set in
      # collection_label_methods and collection_value_methods. For some ruby core
      # classes sensible defaults have been defined. It will use and delete the options
      # :label_method and :value_methods when present.
      #
      def detect_label_and_value_method!(collection, options = {})
        sample = collection.first || collection.last

        case sample
        when Array
          label, value = :first, :last
        when Integer
          label, value = :to_s, :to_i
        when String, NilClass
          label, value = :to_s, :to_s
        end

        # Order of preference: user supplied method, class defaults, auto-detect
        label = options[:label_method] || label || collection_label_methods.find { |m| sample.respond_to?(m) }
        value = options[:value_method] || value || collection_value_methods.find { |m| sample.respond_to?(m) }

        [label, value]
      end

      # Return the label collection method when none is supplied using the
      # values set in collection_label_methods.
      #
      def detect_label_method(collection) #:nodoc:
        detect_label_and_value_method!(collection).first
      end

      # Detects the method to call for fetching group members from the groups when grouping select options
      #
      def detect_group_association(method, group_by)
        object_to_method_reflection = reflection_for(method)
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
        if reflection = reflection_for(method)
          if [:has_and_belongs_to_many, :has_many].include?(reflection.macro)
            "#{method.to_s.singularize}_ids"
          elsif reflection.respond_to? :foreign_key
            reflection.foreign_key
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

      # Returns the active validations for the given method or an empty Array if no validations are
      # found for the method.
      #
      # By default, the if/unless options of the validations are evaluated and only the validations
      # that should be run for the current object state are returned. Pass :all to the last
      # parameter to return :all validations regardless of if/unless options.
      #
      # Requires the ValidationReflection plugin to be present or an ActiveModel. Returns an epmty
      # Array if neither is the case.
      #
      def validations_for(method, mode = :active)
        # ActiveModel?
        validations = if @object && @object.class.respond_to?(:validators_on)
          @object.class.validators_on(method)
        else
          # ValidationReflection plugin?
          if @object && @object.class.respond_to?(:reflect_on_validations_for)
            @object.class.reflect_on_validations_for(method)
          else
            []
          end
        end

        validations = validations.select do |validation|
          (validation.options.present? ? options_require_validation?(validation.options) : true)
        end unless mode == :all

        return validations
      end

      # Generates default_string_options by retrieving column information from
      # the database.
      #
      def default_string_options(method, type) #:nodoc:
        def get_maxlength_for(method)
          validation = validations_for(method).find do |validation|
            (validation.respond_to?(:macro) && validation.macro == :validates_length_of) || # Rails 2 validation
            (validation.respond_to?(:kind) && validation.kind == :length) # Rails 3 validator
          end

          if validation
            validation.options[:maximum] || (validation.options[:within].present? ? validation.options[:within].max : nil)
          else
            nil
          end
        end

        validation_max_limit = get_maxlength_for(method)
        column = column_for(method)

        if type == :text
          { :rows => default_text_area_height, 
            :cols => default_text_area_width }
        elsif type == :numeric || column.nil? || !column.respond_to?(:limit) || column.limit.nil?
          { :maxlength => validation_max_limit,
            :size => default_text_field_size }
        else
          { :maxlength => validation_max_limit || column.limit,
            :size => default_text_field_size }
        end
      end

      # Generate the html id for the li tag.
      # It takes into account options[:index] and @auto_index to generate li
      # elements with appropriate index scope. It also sanitizes the object
      # and method names.
      #
      def generate_html_id(method_name, value='input') #:nodoc:
        index = if options.has_key?(:index)
                  options[:index]
                elsif defined?(@auto_index)
                  @auto_index
                else
                  ""
                end
        sanitized_method_name = method_name.to_s.gsub(/[\?\/\-]$/, '')

        [@@custom_namespace, sanitized_object_name, index, sanitized_method_name, value].reject{|x|x.blank?}.join('_')
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
        if @object && @object.class.respond_to?(:human_attribute_name)
          humanized_name = @object.class.human_attribute_name(method.to_s)
          if humanized_name == method.to_s.send(:humanize)
            method.to_s.send(label_str_method)
          else
            humanized_name
          end
        else
          method.to_s.send(label_str_method)
        end
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
      #   'formtastic.%{type}.%{model}.%{action}.%{attribute}'
      #   'formtastic.%{type}.%{model}.%{attribute}'
      #   'formtastic.%{type}.%{attribute}'
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
          escape_html_entities(value)
        else
          use_i18n = value.nil? ? i18n_lookups_by_default : (value != false)

          if use_i18n
            model_name, nested_model_name  = normalize_model_name(self.model_name.underscore)
            action_name = template.params[:action].to_s rescue ''
            attribute_name = key.to_s

            defaults = ::Formtastic::I18n::SCOPES.reject do |i18n_scope|
              nested_model_name.nil? && i18n_scope.match(/nested_model/)
            end.collect do |i18n_scope|
              i18n_path = i18n_scope.dup
              i18n_path.gsub!('%{action}', action_name)
              i18n_path.gsub!('%{model}', model_name)
              i18n_path.gsub!('%{nested_model}', nested_model_name) unless nested_model_name.nil?
              i18n_path.gsub!('%{attribute}', attribute_name)
              i18n_path.gsub!('..', '.')
              i18n_path.to_sym
            end
            defaults << ''

            defaults.uniq!

            default_key = defaults.shift
            i18n_value = ::Formtastic::I18n.t(default_key,
              options.merge(:default => defaults, :scope => type.to_s.pluralize.to_sym))
            if i18n_value.blank? && type == :label
              # This is effectively what Rails label helper does for i18n lookup
              options[:scope] = [:helpers, type]
              options[:default] = defaults
              i18n_value = ::I18n.t(default_key, options)
            end
            i18n_value = escape_html_entities(i18n_value) if i18n_value.is_a?(::String)
            i18n_value.blank? ? nil : i18n_value
          end
        end
      end

      def model_name
        @object.present? ? @object.class.name : @object_name.to_s.classify
      end

      def normalize_model_name(name)
        if name =~ /(.+)\[(.+)\]/
          [$1, $2]
        else
          [name]
        end
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
          options[:include_blank] = include_blank_for_select_by_default
        end
        options
      end

      def escape_html_entities(string) #:nodoc:
        if escape_html_entities_in_hints_and_labels
          # Acceppt html_safe flag as indicator to skip escaping
          string = template.escape_once(string) unless string.respond_to?(:html_safe?) && string.html_safe? == true
        end
        string
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
    @@default_form_class = 'formtastic'
    mattr_accessor :builder, :default_form_class

    # Override the default ActiveRecordHelper behaviour of wrapping the input.
    # This gets taken care of semantically by adding an error class to the LI tag
    # containing the input.
    #
    FIELD_ERROR_PROC = proc do |html_tag, instance_tag|
      html_tag
    end

    def with_custom_field_error_proc(&block)
      default_field_error_proc = ::ActionView::Base.field_error_proc
      ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
      yield
    ensure
      ::ActionView::Base.field_error_proc = default_field_error_proc
    end

    def semantic_remote_form_for_wrapper(record_or_name_or_array, *args, &proc)
      options = args.extract_options!
      if respond_to? :remote_form_for
        semantic_remote_form_for_real(record_or_name_or_array, *(args << options), &proc)
      else
        options[:remote] = true
        semantic_form_for(record_or_name_or_array, *(args << options), &proc)
      end
    end

    [:form_for, :fields_for, :remote_form_for].each do |meth|
      module_eval <<-END_SRC, __FILE__, __LINE__ + 1
        def semantic_#{meth}(record_or_name_or_array, *args, &proc)
          options = args.extract_options!
          options[:builder] ||= @@builder
          options[:html] ||= {}
          @@builder.custom_namespace = options[:namespace].to_s

          singularizer = defined?(ActiveModel::Naming.singular) ? ActiveModel::Naming.method(:singular) : ActionController::RecordIdentifier.method(:singular_class_name)

          class_names = options[:html][:class] ? options[:html][:class].split(" ") : []
          class_names << @@default_form_class
          class_names << case record_or_name_or_array
            when String, Symbol then record_or_name_or_array.to_s                                  # :post => "post"
            when Array then options[:as] || singularizer.call(record_or_name_or_array.last.class)  # [@post, @comment] # => "comment"
            else options[:as] || singularizer.call(record_or_name_or_array.class)                  # @post => "post"
          end
          options[:html][:class] = class_names.join(" ")

          with_custom_field_error_proc do
            #{meth}(record_or_name_or_array, *(args << options), &proc)
          end
        end
      END_SRC
    end
    alias :semantic_remote_form_for_real :semantic_remote_form_for
    alias :semantic_remote_form_for :semantic_remote_form_for_wrapper
    alias :semantic_form_remote_for :semantic_remote_form_for

  end
end

