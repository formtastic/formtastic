# -*- coding: utf-8 -*-
module Formtastic
  module Helpers

    # {#input} is used to render all content (labels, form widgets, error messages, hints, etc) for
    # a single form input (or field), usually representing a single method or attribute on the
    # form's object or model.
    #
    # The content is wrapped in an `<li>` tag, so it's usually called inside an {Formtastic::Helpers::InputsHelper#inputs inputs} block
    # (which renders an `<ol>` inside a `<fieldset>`), which should be inside a {Formtastic::Helpers::FormHelper#semantic_form_for `semantic_form_for`}
    # block:
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
    #             ...
    #           </li>
    #           <li class="text required" id="post_body_input">
    #             ...
    #           </li>
    #         </ol>
    #       </fieldset>
    #     </form>
    #
    # @see #input
    # @see Formtastic::Helpers::InputsHelper#inputs
    # @see Formtastic::Helpers::FormHelper#semantic_form_for
    module InputHelper
      INPUT_CLASS_DEPRECATION = 'configure Formtastic::FormBuilder.input_class_finder instead (upgrade guide on wiki: http://bit.ly/1F9QtKc )'.freeze
      private_constant(:INPUT_CLASS_DEPRECATION)

      include Formtastic::Helpers::Reflection
      include Formtastic::Helpers::FileColumnDetection

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
      # * `:boolean`          (see {Inputs::BooleanInput})
      # * `:check_boxes`      (see {Inputs::CheckBoxesInput})
      # * `:color`            (see {Inputs::ColorInput})
      # * `:country`          (see {Inputs::CountryInput})
      # * `:datetime_select`  (see {Inputs::DatetimeSelectInput})
      # * `:date_select`      (see {Inputs::DateSelectInput})
      # * `:email`            (see {Inputs::EmailInput})
      # * `:file`             (see {Inputs::FileInput})
      # * `:hidden`           (see {Inputs::HiddenInput})
      # * `:number`           (see {Inputs::NumberInput})
      # * `:password`         (see {Inputs::PasswordInput})
      # * `:phone`            (see {Inputs::PhoneInput})
      # * `:radio`            (see {Inputs::RadioInput})
      # * `:search`           (see {Inputs::SearchInput})
      # * `:select`           (see {Inputs::SelectInput})
      # * `:string`           (see {Inputs::StringInput})
      # * `:text`             (see {Inputs::TextInput})
      # * `:time_zone`        (see {Inputs::TimeZoneInput})
      # * `:time_select`      (see {Inputs::TimeSelectInput})
      # * `:url`              (see {Inputs::UrlInput})
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
      # @option options :multiple [Boolean]
      #   Specify if the `:select` input should allow multiple selections or not (defaults to `belongs_to` associations, and `true` for `has_many` and `has_and_belongs_to_many` associations)
      #
      # @option options :include_blank [Boolean]
      #   Specify if a `:select` input should include a blank option or not (defaults to `include_blank_for_select_by_default` configuration)
      #
      # @option options :prompt [String]
      #   Specify the text in the first ('blank') `:select` input `<option>` to prompt a user to make a selection (implicitly sets `:include_blank` to `true`)
      #
      # @todo Can we deprecate & kill `:label`, `:hint` & `:prompt`? All strings could be shifted to i18n!
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
      # @example Providing HTML5 placeholder text through i18n:
      #   en:
      #    formtastic:
      #      placeholders:
      #        user:
      #          email: "you@yours.com"
      #          first_name: "Joe"
      #          last_name: "Smith"
      #
      # @see #namespaced_input_class
      # @todo Many many more examples. Some of the detail probably needs to be pushed out to the relevant methods too.
      # @todo More i18n examples.
      def input(method, options = {})
        method = method.to_sym
        options = options.dup # Allow options to be shared without being tainted by Formtastic
        options[:as] ||= default_input_type(method, options)

        klass = input_class(options[:as])

        klass.new(self, template, @object, @object_name, method, options).to_html
      end

      protected

      # First try if we can detect special things like :file. With CarrierWave the method does have
      # an underlying column so we don't want :string to get selected.
      #
      # For methods that have a database column, take a best guess as to what the input method
      # should be.  In most cases, it will just return the column type (eg :string), but for special
      # cases it will simplify (like the case of :integer, :float & :decimal to :number), or do
      # something different (like :password and :select).
      #
      # If there is no column for the method (eg "virtual columns" with an attr_accessor), the
      # default is a :string, a similar behaviour to Rails' scaffolding.
      def default_input_type(method, options = {}) # @private
        if @object
          return :select  if reflection_for(method)

          return :file    if is_file?(method, options)
        end

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
            return :color     if method.to_s =~ /color/
          when :integer
            return :select    if reflection_for(method)
            return :number
          when :float, :decimal
            return :number
          when :datetime, :timestamp
            return :datetime_select
          when :time
            return :time_select
          when :date
            return :date_select
          end

          # Try look for hints in options hash. Quite common senario: Enum keys stored as string in the database.
          return :select    if column.type == :string && options.key?(:collection)
          # Try 3: Assume the input name will be the same as the column type (e.g. string_input).
          return column.type
        else
          return :select    if options.key?(:collection)
          return :password  if method.to_s =~ /password/
          return :string
        end
      end

      # Get a column object for a specified attribute method - if possible.
      def column_for(method) # @private
        if @object.respond_to?(:column_for_attribute)
          # Remove deprecation wrapper & review after Rails 5.0 ships
          ActiveSupport::Deprecation.silence do
            @object.column_for_attribute(method)
          end
        end
      end

      # Takes the `:as` option and attempts to return the corresponding input
      # class. In the case of `:as => :awesome` it will first attempt to find a
      # top level `AwesomeInput` class (to allow the application to subclass
      # and modify to suit), falling back to `Formtastic::Inputs::AwesomeInput`.
      #
      # Custom input namespaces to look into can be configured via the
      # {Formtastic::FormBuilder.input_namespaces} configuration setting.
      #
      # @param [Symbol] as A symbol representing the type of input to render
      # @raise [Formtastic::UnknownInputError] An appropriate input class could not be found
      # @return [Class] An input class constant
      #
      # @example Normal use
      #   input_class(:string) #=> Formtastic::Inputs::StringInput
      #   input_class(:date) #=> Formtastic::Inputs::DateInput
      #
      # @example When a top-level class is found
      #   input_class(:string) #=> StringInput
      #   input_class(:awesome) #=> AwesomeInput
      # @see NamespacedClassFinder#find
      def namespaced_input_class(as)
        @input_class_finder ||= input_class_finder.new(self)
        @input_class_finder.find(as)
      rescue Formtastic::InputClassFinder::NotFoundError
        raise Formtastic::UnknownInputError, "Unable to find input #{$!.message}"
      end

      # @api private
      # @deprecated Use {#namespaced_input_class} instead.
      def input_class(as)
        return namespaced_input_class(as) if input_class_finder

        input_class_deprecation_warning(__method__)

        @input_classes_cache ||= {}
        @input_classes_cache[as] ||= begin
          config = Rails.application.config
          use_const_defined = config.respond_to?(:eager_load) ? config.eager_load : config.cache_classes
          use_const_defined ? input_class_with_const_defined(as) : input_class_by_trying(as)
        end
      end

      # @api private
      # @deprecated Use {InputClassFinder#find} instead.
      # prevent exceptions in production environment for better performance
      def input_class_with_const_defined(as)
        input_class_name = custom_input_class_name(as)

        if ::Object.const_defined?(input_class_name)
          input_class_name.constantize
        elsif Formtastic::Inputs.const_defined?(input_class_name)
          standard_input_class_name(as).constantize
        else
          raise Formtastic::UnknownInputError, "Unable to find input class #{input_class_name}"
        end
      end

      # @api private
      # @deprecated Use {InputClassFinder#find} instead.
      # use auto-loading in development environment
      def input_class_by_trying(as)
        begin
          custom_input_class_name(as).constantize
        rescue NameError
          standard_input_class_name(as).constantize
        end
      rescue NameError
        raise Formtastic::UnknownInputError, "Unable to find input class for #{as}"
      end

      # @api private
      # @deprecated Use {InputClassFinder#class_name} instead.
      # :as => :string # => StringInput
      def custom_input_class_name(as)
        input_class_deprecation_warning(__method__)
        "#{as.to_s.camelize}Input"
      end

      # @api private
      # @deprecated Use {InputClassFinder#class_name} instead.
      # :as => :string # => {Formtastic::Inputs::StringInput}
      def standard_input_class_name(as)
        input_class_deprecation_warning(__method__)
        "Formtastic::Inputs::#{as.to_s.camelize}Input"
      end

      private

      def input_class_deprecation_warning(method)
        @input_class_deprecation_warned ||=
            Formtastic.deprecation.deprecation_warning(method, INPUT_CLASS_DEPRECATION, caller(2))
      end

    end
  end
end
