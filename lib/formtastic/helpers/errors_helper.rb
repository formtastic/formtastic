module Formtastic
  module Helpers
    module ErrorsHelper
      include Formtastic::Helpers::FileColumnDetection
      include Formtastic::Helpers::Reflection
      include Formtastic::LocalizedString

      INLINE_ERROR_TYPES = [:sentence, :list, :first]

      # Generates an unordered list of error messages on the base object and optionally for a given
      # set of named attribute. This is idea for rendering a block of error messages at the top of
      # the form for hidden/special/virtual attributes (the Paperclip Rails plugin does this), or
      # errors on the base model.
      #
      # A hash can be used as the last set of arguments to pass HTML attributes to the `<ul>`
      # wrapper.
      #
      # @example A list of errors on the base model
      #   <%= semantic_form_for ... %>
      #     <%= f.semantic_errors %>
      #     ...
      #   <% end %>
      #
      # @example A list of errors on the base and named attributes
      #   <%= semantic_form_for ... %>
      #     <%= f.semantic_errors :something_special %>
      #     ...
      #   <% end %>
      #
      # @example A list of errors on the base model, with custom HTML attributes
      #   <%= semantic_form_for ... %>
      #     <%= f.semantic_errors :class => "awesome" %>
      #     ...
      #   <% end %>
      #
      # @example A list of errors on the base model and named attributes, with custom HTML attributes
      #   <%= semantic_form_for ... %>
      #     <%= f.semantic_errors :something_special, :something_else, :class => "awesome", :onclick => "Awesome();" %>
      #     ...
      #   <% end %>
      def semantic_errors(*args)
        html_options = args.extract_options!
        args = args - [:base]
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
      #
      # @deprecated See the README for the currently supported approach to custom inputs.
      def inline_errors_for(method, options = {})
        ActiveSupport::Deprecation.warn('inline_errors_for and errors_on are deprecated and will be removed on or after version 2.1', caller)
        if render_inline_errors?
          errors = error_keys(method, options).map{|x| @object.errors[x] }.flatten.compact.uniq
          send(:"error_#{inline_errors}", [*errors], options) if errors.any?
        else
          nil
        end
      end
      alias :errors_on :inline_errors_for
      

      protected
      
      # @deprecated This should be removed with inline_errors_for in 2.1
      def error_sentence(errors, options = {})
        error_class = options[:error_class] || default_inline_error_class
        template.content_tag(:p, Formtastic::Util.html_safe(errors.to_sentence.untaint), :class => error_class)
      end
      
      # @deprecated This should be removed with inline_errors_for in 2.1
      def error_list(errors, options = {})
        error_class = options[:error_class] || default_error_list_class
        list_elements = []
        errors.each do |error|
          list_elements <<  template.content_tag(:li, Formtastic::Util.html_safe(error.untaint))
        end
        template.content_tag(:ul, Formtastic::Util.html_safe(list_elements.join("\n")), :class => error_class)
      end
      
      # @deprecated This should be removed with inline_errors_for in 2.1
      def error_first(errors, options = {})
        error_class = options[:error_class] || default_inline_error_class
        template.content_tag(:p, Formtastic::Util.html_safe(errors.first.untaint), :class => error_class)
      end

      def error_keys(method, options)
        @methods_for_error ||= {}
        @methods_for_error[method] ||= begin
          methods_for_error = [method.to_sym]
          methods_for_error << file_metadata_suffixes.map{|suffix| "#{method}_#{suffix}".to_sym} if is_file?(method, options)
          methods_for_error << [association_primary_key_for_method(method)] if [:belongs_to, :has_many].include? association_macro_for_method(method)
          methods_for_error.flatten.compact.uniq
        end
      end

      def has_errors?(method, options)
        methods_for_error = error_keys(method,options)
        @object && @object.respond_to?(:errors) && methods_for_error.any?{|error| !@object.errors[error].blank?}
      end

      def render_inline_errors?
        @object && @object.respond_to?(:errors) && Formtastic::FormBuilder::INLINE_ERROR_TYPES.include?(inline_errors)
      end
    end
  end
end