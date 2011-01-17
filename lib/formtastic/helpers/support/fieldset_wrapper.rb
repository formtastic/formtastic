module Formtastic
  module Helpers
    module Support
      module FieldsetWrapper
    
        protected
        
        # Generates a fieldset and wraps the content in an ordered list. When working
        # with nested attributes, it allows %i as interpolation option in :name. So you can do:
        #
        #   f.inputs :name => 'Task #%i', :for => :tasks
        #
        # or the shorter equivalent:
        #
        #   f.inputs 'Task #%i', :for => :tasks
        #
        # And it will generate a fieldset for each task with legend 'Task #1', 'Task #2',
        # 'Task #3' and so on.
        #
        # Note: Special case for the inline inputs (non-block):
        #   f.inputs "My little legend", :title, :body, :author   # Explicit legend string => "My little legend"
        #   f.inputs :my_little_legend, :title, :body, :author    # Localized (118n) legend with I18n key => I18n.t(:my_little_legend, ...)
        #   f.inputs :title, :body, :author                       # First argument is a column => (no legend)
        def field_set_and_list_wrapping(*args, &block) #:nodoc:
          contents = args.last.is_a?(::Hash) ? '' : args.pop.flatten
          html_options = args.extract_options!
        
          legend  = html_options.dup.delete(:name).to_s
          legend %= parent_child_index(html_options[:parent]) if html_options[:parent]
          legend  = template.content_tag(:legend, template.content_tag(:span, Formtastic::Util.html_safe(legend))) unless legend.blank?
        
          if block_given?
            contents = if template.respond_to?(:is_haml?) && template.is_haml?
              template.capture_haml(&block)
            else
              template.capture(&block)
            end
          end
        
          # Ruby 1.9: String#to_s behavior changed, need to make an explicit join.
          contents = contents.join if contents.respond_to?(:join)
          fieldset = template.content_tag(:fieldset,
            Formtastic::Util.html_safe(legend) << template.content_tag(:ol, Formtastic::Util.html_safe(contents)),
            html_options.except(:builder, :parent)
          )
        
          fieldset
        end
      end
    end
  end
end