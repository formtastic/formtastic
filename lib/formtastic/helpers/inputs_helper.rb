module Formtastic
  module Helpers

    # InputsHelper encapsulates the responsibilties of the {#inputs} and {#input} helpers at the core of the
    # Formtastic DSL.
    #
    # {#inputs} is used to wrap a series of form items in a `<fieldset>` and `<ol>`, with each item
    # in the list containing the markup representing a single {#input}.
    #
    # {#inputs} is usually called with a block containing a series of {#input} calls:
    #
    #     <%= semantic_form_for @post do |f| %>
    #       <%= f.inputs do %>
    #         <%= f.input :title %>
    #         <%= f.input :body %>
    #       <% end %>
    #     <% end %>
    #
    # The HTML output will be something like:
    #
    #     <form class="formtastic" method="post" action="...">
    #       <fieldset>
    #         <ol>
    #           <li class="string required" id="post_title_input">
    #             <label for="post_title">Title*</label>
    #             <input type="text" name="post[title]" id="post_title" value="" required="required">
    #           </li>
    #           <li class="text required" id="post_body_input">
    #             <label for="post_title">Title*</label>
    #             <textarea name="post[body]" id="post_body" required="required"></textarea>
    #           </li>
    #         </ol>
    #       </fieldset>
    #     </form>
    #
    # It's important to note that the `semantic_form_for` and {#inputs} blocks wrap the
    # standard Rails `form_for` helper and form builder, so you have full access to every standard
    # Rails form helper, with any HTML markup and ERB syntax, allowing you to "break free" from
    # Formtastic when it doesn't suit:
    #
    #     <%= semantic_form_for @post do |f| %>
    #       <%= f.inputs do %>
    #         <%= f.input :title %>
    #         <li>
    #           <%= f.text_area :body %>
    #         <li>
    #       <% end %>
    #     <% end %>
    #
    # There are many other syntax variations and arguments to customize your form. See the
    # full documentation of {#inputs} and {#input} for details.
    module InputsHelper
      include Formtastic::Helpers::FieldsetWrapper
      include Formtastic::Helpers::FileColumnDetection
      include Formtastic::Reflection
      include Formtastic::LocalizedString

      # Which columns to skip when automatically rendering a form without any fields specified.
      SKIPPED_COLUMNS = [:created_at, :updated_at, :created_on, :updated_on, :lock_version, :version]

      # Returns a chunk of HTML markup for a given `method` on the form object, wrapped in
      # an `<li>` wrapper tag with appropriate `class` and `id` attribute hooks for CSS and JS.
      # In many cases, the contents of the wrapper will be as simple as a `<label>` and an `<input>`:
      #
      #     <%= f.input :title, :as => :string, :required => true %>
      #
      #     <li class="string required" id="post_title_input">
      #       <label for="post_title">Title<abbr title="Required">*</abbr></label>
      #       <input type="text" name="post[title]" value="" id="post_title" required="required">
      #     </li>
      #
      # In other cases (like a series of checkboxes for a `has_many` relationship), the wrapper may
      # include more complex markup, like a nested `<fieldset>` with a `<legend>` and an `<ol>` of
      # checkbox/label pairs for each choice:
      #
      #     <%= f.input :categories, :as => :check_boxes, :collection => Category.active.ordered %>
      #
      #     <li class="check_boxes" id="post_categories_input">
      #       <fieldset>
      #         <legend>Categories</legend>
      #         <ol>
      #           <li>
      #             <label><input type="checkbox" name="post[categories][1]" value="1"> Ruby</label>
      #           </li>
      #           <li>
      #             <label><input type="checkbox" name="post[categories][2]" value="2"> Rails</label>
      #           </li>
      #           <li>
      #             <label><input type="checkbox" name="post[categories][2]" value="2"> Awesome</label>
      #           </li>
      #         </ol>
      #       </fieldset>
      #     </li>
      #
      # Sensible defaults for all options are guessed by looking at the method name, database column
      # information, association information, validation information, etc. For example, a `:string`
      # database column will map to a `:string` input, but if the method name contains 'email', will
      # map to an `:email` input instead. `belongs_to` associations will have a `:select` input, etc.
      #
      # Formtastic supports many different styles of inputs, and you can/should override the default
      # with the `:as` option. Internally, the symbol is used to map to a protected method
      # responsible for the details. For example, `:as => :string` will map to `string_input`,
      # defined in a module of the same name. Detailed documentation for each input style and it's
      # supported options is available on the `*_input` method in each module (links provided below).
      #
      # Available input styles:
      #
      # * `:boolean`      (see {Inputs::BooleanInput})
      # * `:check_boxes`  (see {Inputs::CheckBoxesInput})
      # * `:country`      (see {Inputs::CountryInput})
      # * `:datetime`     (see {Inputs::DatetimeInput})
      # * `:date`         (see {Inputs::DateInput})
      # * `:email`        (see {Inputs::EmailInput})
      # * `:file`         (see {Inputs::FileInput})
      # * `:hidden`       (see {Inputs::HiddenInput})
      # * `:number`       (see {Inputs::NumberInput})
      # * `:password`     (see {Inputs::PasswordInput})
      # * `:phone`        (see {Inputs::PhoneInput})
      # * `:radio`        (see {Inputs::RadioInput})
      # * `:search`       (see {Inputs::SearchInput})
      # * `:select`       (see {Inputs::SelectInput})
      # * `:string`       (see {Inputs::StringInput})
      # * `:text`         (see {Inputs::TextInput})
      # * `:time_zone`    (see {Inputs::TimeZoneInput})
      # * `:time`         (see {Inputs::TimeInput})
      # * `:url`          (see {Inputs::UrlInput})
      #
      # Calling `:as => :string` (for example) will call `#to_html` on a new instance of 
      # `Formtastic::Inputs::StringInput`. Before this, Formtastic will try to instantiate a top-level
      # namespace StringInput, meaning you can subclass and modify `Formtastic::Inputs::StringInput` 
      # in `app/inputs/`. This also means you can create your own new input types in `app/inputs/`.
      #
      # @todo document the "guessing" of input style
      #
      # @param [Symbol] method
      #   The database column or method name on the form object that this input represents
      #
      # @option options :as [Symbol]
      #   Override the style of input should be rendered
      #
      # @option options :label [String, Symbol, false]
      #   Override the label text
      #
      # @option options :hint [String, Symbol, false]
      #   Override hint text
      #
      # @option options :required [Boolean]
      #   Override to mark the input as required (or not) — adds a required/optional class to the wrapper, and a HTML5 required attribute to the `<input>`
      #
      # @option options :input_html [Hash]
      #   Override or add to the HTML attributes to be passed down to the `<input>` tag
      #
      # @option options :wrapper_html [Hash]
      #   Override or add to the HTML attributes to be passed down to the wrapping `<li>` tag
      #
      # @option options :collection [Array<ActiveModel, String, Symbol>, Hash{String => String, Boolean}, OrderedHash{String => String, Boolean}]
      #   Override collection of objects in the association (`:select`, `:radio` & `:check_boxes` inputs only)
      #
      # @option options :label_method [Symbol, Proc]
      #   Override the method called on each object in the `:collection` for use as the `<label>` content (`:check_boxes` & `:radio` inputs) or `<option>` content (`:select` inputs)
      #
      # @option options :value_method [Symbol, Proc]
      #   Override the method called on each object in the `:collection` for use as the `value` attribute in the `<input>` (`:check_boxes` & `:radio` inputs) or `<option>` (`:select` inputs)
      #
      # @option options :hint_class [String]
      #   Override the `class` attribute applied to the `<p>` tag used when a `:hint` is rendered for an input
      #
      # @option options :error_class [String]
      #   Override the `class` attribute applied to the `<p>` or `<ol>` tag used when inline errors are rendered for an input
      #
      # @option options :multiple [Boolean]
      #   Specify if the `:select` input should allow multiple selections or not (defaults to `belongs_to` associations, and `true` for `has_many` and `has_and_belongs_to_many` associations)
      #
      # @option options :group_by [Symbol]
      #   TODO will probably be deprecated
      #
      # @option options :find_options [Symbol]
      #   TODO will probably be deprecated
      #
      # @option options :group_label_method [Symbol]
      #   TODO will probably be deprecated
      #
      # @option options :include_blank [Boolean]
      #   Specify if a `:select` input should include a blank option or not (defaults to `include_blank_for_select_by_default` configuration)
      #
      # @option options :prompt [String]
      #   Specify the text in the first ('blank') `:select` input `<option>` to prompt a user to make a selection (implicitly sets `:include_blank` to `true`)
      #
      # @todo Can we kill `:hint_class` & `:error_class`? What's the use case for input-by-input? Shift to config or burn!
      # @todo Can we kill `:group_by` & `:group_label_method`? Should be done with :collection => grouped_options_for_select(...)
      # @todo Can we kill `:find_options`? Should be done with MyModel.some_scope.where(...).order(...).whatever_scope
      # @todo Can we kill `:label`, `:hint` & `:prompt`? All strings could be shifted to i18n!
      #
      # @example Accept all default options
      #   <%= f.input :title %>
      #
      # @example Change the input type
      #   <%= f.input :title, :as => :string %>
      #
      # @example Changing the label with a String
      #   <%= f.input :title, :label => "Post title" %>
      #
      # @example Disabling the label with false, even if an i18n translation exists
      #   <%= f.input :title, :label => false  %>
      #
      # @example Changing the hint with a String
      #   <%= f.input :title, :hint => "Every post needs a title!" %>
      #
      # @example Disabling the hint with false, even if an i18n translation exists
      #   <%= f.input :title, :hint => false  %>
      #
      # @example Marking a field as required or not (even if validations do not enforce it)
      #   <%= f.input :title, :required => true  %>
      #   <%= f.input :title, :required => false  %>
      #
      # @example Changing or adding to HTML attributes in the main `<input>` or `<select>` tag
      #   <%= f.input :title, :input_html => { :onchange => "somethingAwesome();", :class => 'awesome' } %>
      #
      # @example Changing or adding to HTML attributes in the wrapper `<li>` tag
      #   <%= f.input :title, :wrapper_html => { :class => "important-input" } %>
      #
      # @example Changing the association choices with `:collection`
      #   <%= f.input :author,     :collection => User.active %>
      #   <%= f.input :categories, :collection => Category.where(...).order(...) %>
      #   <%= f.input :status,     :collection => ["Draft", "Published"] %>
      #   <%= f.input :status,     :collection => [:draft, :published] %>
      #   <%= f.input :status,     :collection => {"Draft" => 0, "Published" => 1} %>
      #   <%= f.input :status,     :collection => OrderedHash.new("Draft" => 0, "Published" => 1) %>
      #   <%= f.input :status,     :collection => [["Draft", 0], ["Published", 1]] %>
      #   <%= f.input :status,     :collection => grouped_options_for_select(...) %>
      #   <%= f.input :status,     :collection => options_for_select(...) %>
      #
      # @example Specifying if a `:select` should allow multiple selections:
      #   <%= f.input :cateogies, :as => :select, :multiple => true %>
      #   <%= f.input :cateogies, :as => :select, :multiple => false %>
      #
      # @example Specifying if a `:select` should have a 'blank' first option to prompt selection:
      #   <%= f.input :author, :as => :select, :include_blank => true %>
      #   <%= f.input :author, :as => :select, :include_blank => false %>
      #
      # @example Specifying the text for a `:select` input's 'blank' first option to prompt selection:
      #   <%= f.input :author, :as => :select, :prompt => "Select an Author" %>
      #
      # @example Modifying an input to suit your needs in `app/inputs`:
      #   class StringInput < Formtastic::Inputs::StringInput
      #     def to_html
      #       puts "this is my custom version of StringInput"      
      #       super
      #     end
      #   end
      #
      # @example Creating your own input to suit your needs in `app/inputs`:
      #   class DatePickerInput
      #     include Formtastic::Inputs::Base
      #     def to_html
      #       # ...
      #     end
      #   end
      #
      # @todo Many many more examples. Some of the detail probably needs to be pushed out to the relevant methods too.
      def input(method, options = {})
        options = options.dup # Allow options to be shared without being tainted by Formtastic
        
        options[:as]     ||= default_input_type(method, options)
        
        begin
          begin
            klass = "#{options[:as].to_s.camelize}Input".constantize # as :string => StringInput
          rescue NameError
            klass = "Formtastic::Inputs::#{options[:as].to_s.camelize}Input".constantize # as :string => Formtastic::Inputs::StringInput
          end
        rescue NameError
          raise Formtastic::UnknownInputError
        end
        
        klass.new(self, template, @object, @object_name, method, options).to_html
      end

      # {#inputs} creates an input fieldset and ol tag wrapping for use around a set of inputs.  It can be
      # called either with a block (in which you can do the usual Rails form stuff, HTML, ERB, etc),
      # or with a list of fields (accepting all default arguments and options). These two examples
      # are functionally equivalent:
      #
      #     # With a block:
      #     <% semantic_form_for @post do |form| %>
      #       <% f.inputs do %>
      #         <%= f.input :title %>
      #         <%= f.input :body %>
      #       <% end %>
      #     <% end %>
      #
      #     # With a list of fields (short hand syntax):
      #     <% semantic_form_for @post do |form| %>
      #       <%= f.inputs :title, :body %>
      #     <% end %>
      #
      #     # Output:
      #     <form ...>
      #       <fieldset class="inputs">
      #         <ol>
      #           <li class="string">...</li>
      #           <li class="text">...</li>
      #         </ol>
      #       </fieldset>
      #     </form>
      #
      # **Quick Forms**
      #
      # Quick, scaffolding-style forms can be easily rendered for rapid early development if called
      # without a block or a field list. In the case an input is rendered for **most** columns in
      # the model's database table (like Rails' scaffolding) plus inputs for some model associations.
      #
      # In this case, all inputs are rendered with default options and arguments. You'll want more
      # control than this in a production application, but it's a great way to get started, then
      # come back later to customise the form with a field list or a block of inputs.  Example:
      #
      #     <% semantic_form_for @post do |form| %>
      #       <%= f.inputs %>
      #     <% end %>
      #
      # **Nested Attributes**
      #
      # One of the most complicated parts of Rails forms comes when nesting the inputs for
      # attrinbutes on associated models. Formtastic can take the pain away for many (but not all)
      # situations.
      #
      # Given the following models:
      #
      #     # Models
      #     class User < ActiveRecord::Base
      #       has_one :profile
      #       accepts_nested_attributes_for :profile
      #     end
      #     class Profile < ActiveRecord::Base
      #       belongs_to :user
      #     end
      #
      # Formtastic provides a helper called `semantic_fields_for`, which wraps around Rails' built-in
      # `fields_for` helper, allowing you to combine Rails-style nested fields with Formtastic inputs:
      #
      #     <% semantic_form_for @user do |form| %>
      #       <%= f.inputs :name, :email %>
      #
      #       <% f.semantic_fields_for :profile do |profile| %>
      #         <% profile.inputs do %>
      #           <%= profile.input :biography %>
      #           <%= profile.input :twitter_name %>
      #           <%= profile.input :shoe_size %>
      #         <% end %>
      #       <% end %>
      #     <% end %>
      #
      # {#inputs} also provides a DSL similar to `semantic_fields_for` to reduce the lines of code a
      # little:
      #
      #     <% semantic_form_for @user do |f| %>
      #       <%= f.inputs :name, :email %>
      #
      #       <% f.inputs :for => :profile do %>
      #         <%= profile.input :biography %>
      #         <%= profile.input :twitter_name %>
      #         <%= profile.input :shoe_size %>
      #       <% end %>
      #     <% end %>
      #
      # The `:for` option also works with short hand syntax:
      #
      #     <% semantic_form_for @post do |form| %>
      #       <%= f.inputs :name, :email %>
      #       <%= f.inputs :biography, :twitter_name, :shoe_size, :for => :profile %>
      #     <% end %>
      #
      # {#inputs} will always create a new `<fieldset>` wrapping, so only use it when it makes sense
      # in the document structure and semantics (using `semantic_fields_for` otherwise).
      #
      # All options except `:name`, `:title` and `:for` will be passed down to the fieldset as HTML
      # attributes (id, class, style, etc).
      #
      #
      # @option *args :for [Symbol, ActiveModel, Array]
      #   The contents of this option is passed down to Rails' fields_for() helper, so it accepts the same values.
      #
      # @option *args :name [String]
      #   The optional name passed into the `<legend>` tag within the fieldset (alias of `:title`)
      #
      # @option *args :title [String]
      #   The optional name passed into the `<legend>` tag within the fieldset (alias of `:name`)
      #
      #
      # @example Quick form: Render a scaffold-like set of inputs for automatically guessed attributes and simple associations on the model, with all default arguments and options
      #   <% semantic_form_for @post do |form| %>
      #     <%= f.inputs %>
      #   <% end %>
      #
      # @example Short hand: Render inputs for a named set of attributes and simple associations on the model, with all default arguments and options
      #   <% semantic_form_for @post do |form| %>
      #     <%= f.inputs, :title, :body, :user, :categories %>
      #   <% end %>
      #
      # @example Block: Render inputs for attributes and simple associations with full control over arguments and options
      #   <% semantic_form_for @post do |form| %>
      #     <%= f.inputs do %>
      #       <%= f.input :title ... %>
      #       <%= f.input :body ... %>
      #       <%= f.input :user ... %>
      #       <%= f.input :categories ... %>
      #     <% end %>
      #   <% end %>
      #
      # @example Multiple blocks: Render inputs in multiple fieldsets
      #   <% semantic_form_for @post do |form| %>
      #     <%= f.inputs do %>
      #       <%= f.input :title ... %>
      #       <%= f.input :body ... %>
      #     <% end %>
      #     <%= f.inputs do %>
      #       <%= f.input :user ... %>
      #       <%= f.input :categories ... %>
      #     <% end %>
      #   <% end %>
      #
      # @example Provide text for the `<legend>` to name a fieldset (with a block)
      #   <% semantic_form_for @post do |form| %>
      #     <%= f.inputs :name => 'Write something:' do %>
      #       <%= f.input :title ... %>
      #       <%= f.input :body ... %>
      #     <% end %>
      #     <%= f.inputs do :name => 'Advanced options:' do %>
      #       <%= f.input :user ... %>
      #       <%= f.input :categories ... %>
      #     <% end %>
      #   <% end %>
      #
      # @example Provide text for the `<legend>` to name a fieldset (with short hand)
      #   <% semantic_form_for @post do |form| %>
      #     <%= f.inputs :title, :body, :name => 'Write something:'%>
      #     <%= f.inputs :user, :cateogies, :name => 'Advanced options:' %>
      #   <% end %>
      #
      # @example Inputs for nested attributes (don't forget `accepts_nested_attributes_for` in your model, see Rails' `fields_for` documentation)
      #   <% semantic_form_for @user do |form| %>
      #     <%= f.inputs do %>
      #       <%= f.input :name ... %>
      #       <%= f.input :email ... %>
      #     <% end %>
      #     <%= f.inputs :for => :profile do |profile| %>
      #       <%= profile.input :user ... %>
      #       <%= profile.input :categories ... %>
      #     <% end %>
      #   <% end %>
      #
      # @example Inputs for nested record (don't forget `accepts_nested_attributes_for` in your model, see Rails' `fields_for` documentation)
      #   <% semantic_form_for @user do |form| %>
      #     <%= f.inputs do %>
      #       <%= f.input :name ... %>
      #       <%= f.input :email ... %>
      #     <% end %>
      #     <%= f.inputs :for => @user.profile do |profile| %>
      #       <%= profile.input :user ... %>
      #       <%= profile.input :categories ... %>
      #     <% end %>
      #   <% end %>
      #
      # @example Inputs for nested record with a different name (don't forget `accepts_nested_attributes_for` in your model, see Rails' `fields_for` documentation)
      #   <% semantic_form_for @user do |form| %>
      #     <%= f.inputs do %>
      #       <%= f.input :name ... %>
      #       <%= f.input :email ... %>
      #     <% end %>
      #     <%= f.inputs :for => [:user_profile, @user.profile] do |profile| %>
      #       <%= profile.input :user ... %>
      #       <%= profile.input :categories ... %>
      #     <% end %>
      #   <% end %>
      #
      # @example Nesting {#inputs} blocks requires an extra `<li>` tag for valid markup
      #   <% semantic_form_for @user do |form| %>
      #     <%= f.inputs do %>
      #       <%= f.input :name ... %>
      #       <%= f.input :email ... %>
      #       <li>
      #         <%= f.inputs :for => [:user_profile, @user.profile] do |profile| %>
      #           <%= profile.input :user ... %>
      #           <%= profile.input :categories ... %>
      #         <% end %>
      #       </li>
      #     <% end %>
      #   <% end %>
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
            args -= SKIPPED_COLUMNS
            args.compact!
          end
          legend = args.shift if args.first.is_a?(::String)
          contents = args.collect { |method| input(method.to_sym) }
          args.unshift(legend) if legend.present?

          field_set_and_list_wrapping(*((args << html_options) << contents))
        end
      end

      # A thin wrapper around Rails' `fields_for` helper to set `:builder => Formtastic::FormBuilder`
      # for nesting forms. Can be used in the same way as `fields_for` (see the Rails documentation),
      # but you'll also have access to Formtastic's helpers ({#input}, etc) inside the block.
      #
      # @example
      #   <% semantic_form_for @post do |post| %>
      #     <% post.semantic_fields_for :author do |author| %>
      #       <% author.inputs :name %>
      #     <% end %>
      #   <% end %>
      #
      #   <form ...>
      #     <fieldset class="inputs">
      #       <ol>
      #         <li class="string"><input type='text' name='post[author][name]' id='post_author_name' /></li>
      #       </ol>
      #     </fieldset>
      #   </form>
      def semantic_fields_for(record_or_name_or_array, *args, &block)
        opts = args.extract_options!
        opts[:builder] ||= self.class
        args.push(opts)
        fields_for(record_or_name_or_array, *args, &block)
      end

      # Generates error messages for the given method, used for displaying errors right near the
      # field for data entry. Uses the `:inline_errors` config to determin the right presentation,
      # which may be an ordered list, a paragraph sentence containing all errors, or a paragraph
      # containing just the first error. If configred to `:none`, no error is shown.
      #
      # See the `:inline_errors` config documentation for more details.
      #
      # This method is mostly used internally, but can be used in your forms when creating your own
      # custom inputs, so it's been made public and aliased to `errors_on`.
      #
      # @example
      #   <%= semantic_form_for @post do |f| %>
      #     <li class='my-custom-text-input'>
      #       <%= f.label(:body) %>
      #       <%= f.text_field(:body) %>
      #       <%= f.errors_on(:body) %>
      #     </li>
      #   <% end %>
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
      def content_columns #:nodoc:
        model_name.constantize.content_columns.collect { |c| c.name.to_sym }.compact rescue []
      end

      # Deals with :for option when it's supplied to inputs methods. Additional
      # options to be passed down to :for should be supplied using :for_options
      # key.
      #
      # It should raise an error if a block with arity zero is given.
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

      # For methods that have a database column, take a best guess as to what the input method
      # should be.  In most cases, it will just return the column type (eg :string), but for special
      # cases it will simplify (like the case of :integer, :float & :decimal to :number), or do
      # something different (like :password and :select).
      #
      # If there is no column for the method (eg "virtual columns" with an attr_accessor), the
      # default is a :string, a similar behaviour to Rails' scaffolding.
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
            return :number
          when :float, :decimal
            return :number
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
      def column_for(method) #:nodoc:
        @object.column_for_attribute(method) if @object.respond_to?(:column_for_attribute)
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