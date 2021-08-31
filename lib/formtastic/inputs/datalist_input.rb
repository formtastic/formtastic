# frozen_string_literal: true
module Formtastic
  module Inputs
    # Outputs a label and a text field, along with a datalist tag
    # datalist tag provides a list of options which drives a simple autocomplete
    # on the text field. This is a HTML5 feature, more info can be found at
    # {https://developer.mozilla.org/en/docs/Web/HTML/Element/datalist <datalist> at MDN}
    # This input accepts a :collection option which takes data in all the usual formats accepted by
    # {http://apidock.com/rails/ActionView/Helpers/FormOptionsHelper/options_for_select options_for_select}
    #
    # @example Input is used as follows
    #   f.input :fav_book, :as => :datalist, :collection => Book.pluck(:name)
    #
    class DatalistInput
      include Base
      include Base::Stringish
      include Base::Collections

      def to_html
        @name = input_html_options[:id].gsub(/_id$/, "")
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
        builder.template.content_tag(:datalist,html, { :id => html_id_of_datalist }, false)
      end
    end
  end
end