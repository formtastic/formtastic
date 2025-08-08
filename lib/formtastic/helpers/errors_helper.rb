# frozen_string_literal: true
module Formtastic
  module Helpers
    module ErrorsHelper
      include Formtastic::Helpers::FileColumnDetection
      include Formtastic::Helpers::Reflection
      include Formtastic::LocalizedString

      INLINE_ERROR_TYPES = [:sentence, :list, :first]

      # Generates an unordered list of error messages on the base object and optionally for a given
      # set of named attributes. This is ideal for rendering a block of error messages at the top of
      # the form for hidden/special/virtual attributes (the Paperclip Rails plugin does this), or
      # errors on the base model.
      #
      # A hash can be used as the last set of arguments to pass HTML attributes to the `<ul>`
      # wrapper.
      #
      # # in config/initializers/formtastic.rb
      # Setting `Formtastic::FormBuilder.semantic_errors_link_to_inputs = true`
      # will render attribute errors as links to the corresponding errored inputs.
      #
      # @example A list of all errors on the model, base errors and all errored attributes
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
      # @example A list of all errors, with custom HTML attributes
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
      #
      # @param [Array<Symbol>] *args Optional attribute names to display errors for.
      #   When empty, displays all errors (base + all errored attributes). HTML options can be passed
      #   as the last argument hash.
      # @return [String, nil] HTML string containing error list, or nil if no errors exist
      def semantic_errors(*args)
        html_options = args.extract_options!
        html_options[:class] ||= "errors"

        args = @object.errors.attribute_names if args.empty?

        if Formtastic::FormBuilder.semantic_errors_link_to_inputs
          attribute_error_hash = semantic_error_hash_from_attributes(args)
          return nil if @object.errors[:base].blank? && attribute_error_hash.blank?

          template.content_tag(:ul, html_options) do
            (
              @object.errors[:base].map { |base_error| template.content_tag(:li, base_error) } <<
              attribute_error_hash.map { |attribute, error_message|
                template.content_tag(:li) do
                  template.content_tag(:a, href: "##{object_name}_#{attribute}") do
                    error_message
                  end
                end
              }
            ).join.html_safe
          end
        else
          full_errors = @object.errors[:base]
          full_errors += semantic_error_list_from_attributes(args)
          return nil if full_errors.blank?

          template.content_tag(:ul, html_options) do
            full_errors.map { |error| template.content_tag(:li, error) }.join.html_safe
          end
        end
      end

      protected

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

      def semantic_error_list_from_attributes(*args)
        attribute_errors = []
        args = args.flatten
        args.each do |attribute|
          next if attribute == :base

          full_message = error_message_for_attribute(attribute)

          attribute_errors << full_message unless full_message.blank?
        end

        attribute_errors
      end

      # returns { 'attribute': 'error_message_for_attribute' }
      def semantic_error_hash_from_attributes(*args)
        attribute_error_hash = {}
        args = args.flatten
        args.each do |attribute|
          next if attribute == :base

          full_message = error_message_for_attribute(attribute)

          attribute_error_hash[attribute] = full_message unless full_message.blank?
        end

        attribute_error_hash
      end

      # Returns "Attribute error_message_sentence" localized, humanized
      def error_message_for_attribute(attribute)
        attribute_string = localized_string(attribute, attribute.to_sym, :label) || humanized_attribute_name(attribute)
        error_message = @object.errors[attribute.to_sym]&.to_sentence

        return nil if error_message.blank?

        full_message = [attribute_string, error_message].join(" ")
        full_message
      end
    end
  end
end
