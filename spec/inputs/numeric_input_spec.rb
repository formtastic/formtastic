# encoding: utf-8
require 'spec_helper'

describe 'numeric input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything

    @form = semantic_form_for(@new_post) do |builder|
      concat(builder.input(:title, :as => :numeric))
    end
  end

  it_should_have_input_wrapper_with_class(:numeric)
  it_should_have_input_wrapper_with_id("post_title_input")
  it_should_have_label_with_text(/Title/)
  it_should_have_label_for("post_title")
  it_should_have_input_with_id("post_title")
  it_should_have_input_with_type(:text)
  it_should_have_input_with_name("post[title]")
  it_should_use_default_text_field_size_when_not_nil(:string)
  it_should_not_use_default_text_field_size_when_nil(:string)
  it_should_apply_custom_input_attributes_when_input_html_provided(:string)
  it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
  it_should_apply_error_logic_for_input_type(:numeric)

  describe "when no object is provided" do
    before do
      @form = semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:title, :as => :numeric))
      end
    end

    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("project_title")
    it_should_have_input_with_id("project_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("project[title]")
  end

  describe "when namespace provided" do
    before do
      @form = semantic_form_for(@new_post, :namespace => :context2) do |builder|
        concat(builder.input(:title, :as => :numeric))
      end
    end

    it_should_have_input_wrapper_with_id("context2_post_title_input")
    it_should_have_label_and_input_with_id("context2_post_title")
  end

end

