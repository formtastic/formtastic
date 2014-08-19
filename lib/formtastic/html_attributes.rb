module Formtastic
  # @private
  module HtmlAttributes
    # Returns a namespace passed by option or inherited from parent builders / class configuration
    def dom_id_namespace
      namespace = options[:custom_namespace]
      parent = options[:parent_builder]

      case
        when namespace then namespace
        when parent && parent != self then parent.dom_id_namespace
        else custom_namespace
      end
    end

    protected

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
