module Formtastic
  # @private
  module HtmlAttributes

    protected

    # Generate the html id for the li tag.
    # It takes into account options[:index] and @auto_index to generate li
    # elements with appropriate index scope. It also sanitizes the object
    # and method names.
    #
    # For those of you wondering (like me), options is part of the fields_for
    # and Builder scope, which is why you can't see it passed in as an arg.
    def generate_html_id(method_name, value='input') #:nodoc:
      index = if options.has_key?(:index)
                options[:index]
              elsif defined?(@auto_index)
                @auto_index
              else
                ""
              end
      sanitized_method_name = method_name.to_s.gsub(/[\?\/\-]$/, '')

      [custom_namespace, sanitized_object_name, index, sanitized_method_name, value].reject{|x|x.blank?}.join('_')
    end

    # Used by FormBuilder generate_html_id
    def sanitized_object_name #:nodoc:
      @sanitized_object_name ||= @object_name.to_s.gsub(/\]\[|[^-a-zA-Z0-9:.]/, "_").sub(/_$/, "")
    end

    def humanized_attribute_name(method)
      if @object && @object.class.respond_to?(:human_attribute_name)
        humanized_name = @object.class.human_attribute_name(method.to_s)
        if humanized_name == method.to_s.send(:humanize)
          method.to_s.send(label_str_method)
        else
          humanized_name
        end
      else
        method.to_s.send(label_str_method)
      end
    end

  end
end