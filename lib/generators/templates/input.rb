class <%= name.camelize %>Input <%= @extension_sentence %>
  <%- if !options[:extend] -%>
  include Formtastic::Inputs::Base
  <%- end -%>

  <%- if !options[:extend] || (options[:extend] == "extend")  -%>
  def to_html
    # Add your custom input definition here.
    <%- if options[:extend] == "extend" -%>
    super
    <%- end -%>
  end

  <%- else -%>
  def input_html_options
    # Add your custom input extension here.
  end
  <%- end -%>
end