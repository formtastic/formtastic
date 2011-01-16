module Formtastic
  module Helpers
    # Wrappers around form_for (etc) with :builder => SemanticFormBuilder.
    #
    # * semantic_form_for(@post)
    # * semantic_fields_for(@post)
    # * semantic_form_remote_for(@post)
    # * semantic_remote_form_for(@post)
    #
    # Each of which are the equivalent of:
    #
    # * form_for(@post, :builder => Formtastic::SemanticFormBuilder))
    # * fields_for(@post, :builder => Formtastic::SemanticFormBuilder))
    # * form_remote_for(@post, :builder => Formtastic::SemanticFormBuilder))
    # * remote_form_for(@post, :builder => Formtastic::SemanticFormBuilder))
    #
    # Example Usage:
    #
    #   <% semantic_form_for @post do |f| %>
    #     <%= f.input :title %>
    #     <%= f.input :body %>
    #   <% end %>
    #
    # The above examples use a resource-oriented style of form_for() helper where only the @post
    # object is given as an argument, but the generic style is also supported, as are forms with
    # inline objects (Post.new) rather than objects with instance variables (@post):
    #
    #   <% semantic_form_for :post, @post, :url => posts_path do |f| %>
    #     ...
    #   <% end %>
    #
    #   <% semantic_form_for :post, Post.new, :url => posts_path do |f| %>
    #     ...
    #   <% end %>
    module FormHelper
      @@builder = ::Formtastic::SemanticFormBuilder
      @@default_form_class = 'formtastic'
      mattr_accessor :builder, :default_form_class
  
      # Override the default ActiveRecordHelper behaviour of wrapping the input.
      # This gets taken care of semantically by adding an error class to the LI tag
      # containing the input.
      #
      FIELD_ERROR_PROC = proc do |html_tag, instance_tag|
        html_tag
      end
  
      def with_custom_field_error_proc(&block)
        default_field_error_proc = ::ActionView::Base.field_error_proc
        ::ActionView::Base.field_error_proc = FIELD_ERROR_PROC
        yield
      ensure
        ::ActionView::Base.field_error_proc = default_field_error_proc
      end
  
      def semantic_remote_form_for_wrapper(record_or_name_or_array, *args, &proc)
        options = args.extract_options!
        if respond_to? :remote_form_for
          semantic_remote_form_for_real(record_or_name_or_array, *(args << options), &proc)
        else
          options[:remote] = true
          semantic_form_for(record_or_name_or_array, *(args << options), &proc)
        end
      end
  
      [:form_for, :fields_for, :remote_form_for].each do |meth|
        module_eval <<-END_SRC, __FILE__, __LINE__ + 1
          def semantic_#{meth}(record_or_name_or_array, *args, &proc)
            options = args.extract_options!
            options[:builder] ||= @@builder
            options[:html] ||= {}
            @@builder.custom_namespace = options[:namespace].to_s
  
            singularizer = defined?(ActiveModel::Naming.singular) ? ActiveModel::Naming.method(:singular) : ActionController::RecordIdentifier.method(:singular_class_name)
  
            class_names = options[:html][:class] ? options[:html][:class].split(" ") : []
            class_names << @@default_form_class
            class_names << case record_or_name_or_array
              when String, Symbol then record_or_name_or_array.to_s                                  # :post => "post"
              when Array then options[:as] || singularizer.call(record_or_name_or_array.last.class)  # [@post, @comment] # => "comment"
              else options[:as] || singularizer.call(record_or_name_or_array.class)                  # @post => "post"
            end
            options[:html][:class] = class_names.join(" ")
  
            with_custom_field_error_proc do
              #{meth}(record_or_name_or_array, *(args << options), &proc)
            end
          end
        END_SRC
      end
      alias :semantic_remote_form_for_real :semantic_remote_form_for
      alias :semantic_remote_form_for :semantic_remote_form_for_wrapper
      alias :semantic_form_remote_for :semantic_remote_form_for
    end
  end
  
  # Quick hack/shim for anything expecting the old SemanticFormHelper module.
  # TODO: migrate everything across
  module SemanticFormHelper
    include Formtastic::Helpers::FormHelper
    @@builder = Formtastic::Helpers::FormHelper.builder
    @@default_form_class = Formtastic::Helpers::FormHelper.default_form_class
    mattr_accessor :builder, :default_form_class
  end

end