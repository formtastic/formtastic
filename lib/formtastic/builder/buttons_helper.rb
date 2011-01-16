module Formtastic
  module Builder
    module ButtonsHelper
      # Creates a fieldset and ol tag wrapping for form buttons / actions as list items.
      # See inputs documentation for a full example.  The fieldset's default class attriute
      # is set to "buttons".
      #
      # See inputs for html attributes and special options.
      def buttons(*args, &block)
        html_options = args.extract_options!
        html_options[:class] ||= "buttons"
    
        if block_given?
          field_set_and_list_wrapping(html_options, &block)
        else
          args = [:commit] if args.empty?
          contents = args.map { |button_name| send(:"#{button_name}_button") }
          field_set_and_list_wrapping(html_options, contents)
        end
      end
    
      # Creates a submit input tag with the value "Save [model name]" (for existing records) or
      # "Create [model name]" (for new records) by default:
      #
      #   <%= form.commit_button %> => <input name="commit" type="submit" value="Save Post" />
      #
      # The value of the button text can be overridden:
      #
      #  <%= form.commit_button "Go" %> => <input name="commit" type="submit" value="Go" class="{create|update|submit}" />
      #  <%= form.commit_button :label => "Go" %> => <input name="commit" type="submit" value="Go" class="{create|update|submit}" />
      #
      # And you can pass html atributes down to the input, with or without the button text:
      #
      #  <%= form.commit_button :button_html => { :class => "pretty" } %> => <input name="commit" type="submit" value="Save Post" class="pretty {create|update|submit}" />
      def commit_button(*args)
        options = args.extract_options!
        text = options.delete(:label) || args.shift
    
        if @object && (@object.respond_to?(:persisted?) || @object.respond_to?(:new_record?))
          key = @object.persisted? ? :update : :create
    
          # Deal with some complications with ActiveRecord::Base.human_name and two name models (eg UserPost)
          # ActiveRecord::Base.human_name falls back to ActiveRecord::Base.name.humanize ("Userpost")
          # if there's no i18n, which is pretty crappy.  In this circumstance we want to detect this
          # fall back (human_name == name.humanize) and do our own thing name.underscore.humanize ("User Post")
          if @object.class.model_name.respond_to?(:human)
            object_name = @object.class.model_name.human
          else
            object_human_name = @object.class.human_name                # default is UserPost => "Userpost", but i18n may do better ("User post")
            crappy_human_name = @object.class.name.humanize             # UserPost => "Userpost"
            decent_human_name = @object.class.name.underscore.humanize  # UserPost => "User post"
            object_name = (object_human_name == crappy_human_name) ? decent_human_name : object_human_name
          end
        else
          key = :submit
          object_name = @object_name.to_s.send(label_str_method)
        end
    
        text = (localized_string(key, text, :action, :model => object_name) ||
                ::Formtastic::I18n.t(key, :model => object_name)) unless text.is_a?(::String)
    
        button_html = options.delete(:button_html) || {}
        button_html.merge!(:class => [button_html[:class], key].compact.join(' '))
    
        wrapper_html_class = ['commit'] # TODO: Add class reflecting on form action.
        wrapper_html = options.delete(:wrapper_html) || {}
        wrapper_html[:class] = (wrapper_html_class << wrapper_html[:class]).flatten.compact.join(' ')
    
        accesskey = (options.delete(:accesskey) || default_commit_button_accesskey) unless button_html.has_key?(:accesskey)
        button_html = button_html.merge(:accesskey => accesskey) if accesskey
        template.content_tag(:li, Formtastic::Util.html_safe(submit(text, button_html)), wrapper_html)
      end
    end
  end
end