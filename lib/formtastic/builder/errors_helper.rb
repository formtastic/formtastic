module Formtastic
  module Builder
    module ErrorsHelper
      
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