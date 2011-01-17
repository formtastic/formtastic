require 'helpers/file_column_detection'
require 'reflection'

module Formtastic
  module Helpers
    module ErrorsHelper
      include Formtastic::Helpers::FileColumnDetection
      include Formtastic::Reflection
      
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
        @object && @object.respond_to?(:errors) && Formtastic::Builder::Base::INLINE_ERROR_TYPES.include?(inline_errors)
      end
      
      def association_macro_for_method(method) #:nodoc:
        reflection = reflection_for(method)
        reflection.macro if reflection
      end
      
      def association_primary_key(method)
        reflection = reflection_for(method)
        reflection.options[:foreign_key] if reflection && !reflection.options[:foreign_key].blank?
        :"#{method}_id"
      end
  
    end
  end
end