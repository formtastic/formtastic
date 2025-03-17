# frozen_string_literal: true
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
        full_errors = {}
        args.each do |attribute|
          full_errors[attribute] = error_message_for_attribute(attribute)
        end
        full_errors.compact_blank!
        base_errors = @object.errors[:base]
        base_errors = Array(@object.errors[:base]) if base_errors.is_a?(String)
        return nil if full_errors.blank? && base_errors.blank?
        html_options[:class] ||= "errors"
        template.content_tag(:ul, html_options) do
          (
            base_errors.map { |base_error| template.content_tag(:li, base_error) } <<
            full_errors.map { |attribute, error_message|
              template.content_tag(:li) do
                template.content_tag(:a, href: "##{object_name}_#{attribute}") do
                  error_message
                end
              end
            }
          ).join.html_safe
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
