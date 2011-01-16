module Formtastic
  module Helpers
    module LabelHelper
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
    end
  end
end
