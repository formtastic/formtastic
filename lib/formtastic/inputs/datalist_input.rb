class DatalistInput
  include Formtastic::Inputs::Base
  include Formtastic::Inputs::Base::Stringish
  include Formtastic::Inputs::Base::Collections

  def to_html
    @name = input_html_options[:id].gsub("_id", "")
    input_wrapping do
      label_html <<
      builder.text_field(method, input_html_options) << # standard input
      data_list_html # append new datalist element
    end
  end

  def input_html_options
    super.merge(:list => html_id_of_datalist)
  end

  def html_id_of_datalist
    "#{@name}_datalist"
  end

  def data_list_html
    html = builder.template.options_for_select(collection)
    builder.template.content_tag(:datalist,html,{:id => html_id_of_datalist}, false)
  end
end
