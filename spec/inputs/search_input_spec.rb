# encoding: utf-8
require 'spec_helper'

describe 'search input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe "when object is provided" do
    before do
      @form = semantic_form_for(@new_post) do |builder|
        concat(builder.input(:search))
      end
    end

    it_should_have_input_wrapper_with_class(:search)
    it_should_have_input_wrapper_with_id("post_search_input")
    it_should_have_label_with_text(/Search/)
    it_should_have_label_for("post_search")
    it_should_have_input_with_id("post_search")
    it_should_have_input_with_type(Formtastic::Util.rails3? ? :search : :text)
    it_should_have_input_with_name("post[search]")

  end

  describe "when namespace is provided" do

    before do
      @form = semantic_form_for(@new_post, :namespace => "context2") do |builder|
        concat(builder.input(:search))
      end
    end

    it_should_have_input_wrapper_with_id("context2_post_search_input")
    it_should_have_label_and_input_with_id("context2_post_search")

  end

end

