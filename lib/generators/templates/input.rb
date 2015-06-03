class <%= name.camelize %>Input <%= @extension_sentence %>
  <%- if !options[:override] && !options[:extend] -%>
  include Formtastic::Inputs::Base
  <%- end -%>

  <%- if !options[:extend] -%>
  def to_html
    # Add your custom input definition here.
    <%- if options[:override] -%>
    super
    <%- end -%>
  end

  <%- else -%>
  def input_html_options
    # Add your custom input extension here.
  end
  <%- end -%>
end