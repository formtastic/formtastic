require 'localized_string'

module Formtastic
  module Helpers
    module LabelHelper
      include Formtastic::LocalizedString
      
      # Generates the label for the input. It's a superset of the functionality of Rails' own `label`
      # helper, meaning that it accepts the same arguments and options, plus some new arguments that
      # are exclusive to Formtastic.
      #
      # It's unlikely you will need call this method direct from your views, but it's been made 
      # public to document the changes made to the Rails method, for the rare occasions when you 
      # might build your own input in the view using regular form helpers.
      #
      # @param [Symbol] method
      #   The method or attribute on the model this label is for (eg `:title` on a `Post`)
      #
      # @param [String, Hash] options_or_text
      #   A string for the text to appear as the content of the `<label>` tag, or a Hash of options (see below)
      #
      # @param [Hash] options
      #   A Hash of options (see below)
      #
      # @option options [String] :label
      #   Override the text for the contents of the `<label>` tag
      #
      # @option options [true, false] :required
      #   Specify if the field required or not. By default this value is "guessed" by reflecting on 
      #   the model validations, with a fallback to `all_fields_required_by_default` configuration. 
      #   Required and optional labels have the `required_string` (defaults to an asterix wrapped 
      #   in an `<abbr>` tag) or `optional_string` configuration variables appended to them.
      #
      # @option options [Symbol] :input_name
      #   Gives the input to match for. This is needed when you want to call `f.label :authors` but 
      #   it should match `:author_ids`.
      #
      #
      # @example Basic usage, just like Rails (except that it searches i18n for the label text too)
      #   <%= semantic_form_for @post do |f| %>
      #     <%= f.label :title %>
      #   <% end %>
      #
      # @example Basic usage with string for label text, just like Rails
      #   <%= semantic_form_for @post do |f| %>
      #     <%= f.label :title, "Your title" %>
      #   <% end %>
      #
      # @example Alternative for label text using `:label` option to match the rest of the Formtastic API
      #   <%= semantic_form_for @post do |f| %>
      #     <%= f.label :title, :label => "Your title" %>
      #   <% end %>
      #
      # @example Mark the label as required or not, regardless of DB, validations and default config.
      #   <%= semantic_form_for @post do |f| %>
      #     <%= f.label :title, :required => true %>
      #     <%= f.label :body, :required => false %>
      #   <% end %>
      #
      #
      # @todo i18n documentation
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
      
      protected
      
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
      
    end
  end
end
