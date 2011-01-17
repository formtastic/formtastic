require 'support/fieldset_wrapper'

module Formtastic
  module Helpers
    module InputsHelper
      include Support::FieldsetWrapper
      
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
            args -= Formtastic::Builder::Base::RESERVED_COLUMNS
            args.compact!
          end
          legend = args.shift if args.first.is_a?(::String)
          contents = args.collect { |method| input(method.to_sym) }
          args.unshift(legend) if legend.present?
    
          field_set_and_list_wrapping(*((args << html_options) << contents))
        end
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
      
      protected
      
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
      
      # Collects content columns (non-relation columns) for the current form object class.
      #
      def content_columns #:nodoc:
        model_name.constantize.content_columns.collect { |c| c.name.to_sym }.compact rescue []
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
            template.concat(contents)
          end
        else
          lambda do |f|
            contents = f.inputs(*args)
            template.concat(contents)
          end
        end
  
        fields_for_args = [options.delete(:for), options.delete(:for_options) || {}].flatten
        semantic_fields_for(*fields_for_args, &fields_for_block)
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
      
      # Get a column object for a specified attribute method - if possible.
      #
      def column_for(method) #:nodoc:
        @object.column_for_attribute(method) if @object.respond_to?(:column_for_attribute)
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
      
    end
  end
end