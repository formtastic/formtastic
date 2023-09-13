# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe "datalist inputs" do
  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  describe "renders correctly" do
    lists_without_values =[
      %w(a b c),
      ["a", "b", "c"],
      ("a".."c")
    ]
    lists_with_values = [
      {a: 1, b: 2, c:3},
      {"a" => 1, "b" => 2, "c" =>3},
      [["a",1], ["b",2], ["c", 3]]
    ]

    def self.common_tests(list)
      it_should_have_label_with_text(/Document/)
      it_should_have_label_for("post_document")
      it_should_have_input_wrapper_with_class(:datalist)
      it_should_have_input_with(id: "post_document", type: :text, list:"post_document_datalist")
      it_should_have_tag_with(:datalist, id: "post_document_datalist" )
      it_should_have_many_tags(:option, list.count)
    end

    context "Rendering list of simple items" do
      lists_without_values.each do |list|
        describe "renders #{list.to_s} correctly" do
          before do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:document, as: :datalist, collection: list))
            end)
          end
          common_tests list
          it_should_have_tag_with :option, value: list.first
        end
      end
    end

    context "Rendering list of complex items, key-value pairs and such" do
      lists_with_values.each do |list|
        describe "renders #{list.to_s} correctly" do
          before do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:document, as: :datalist, collection: list))
            end)
          end
          common_tests list
          it_should_have_tag_with :option, value: list.first.last
        end
      end
    end
  end
end