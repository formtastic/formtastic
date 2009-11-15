# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'string input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:title, :as => :string))
    end
  end

  it_should_have_input_wrapper_with_class(:string)
  it_should_have_input_wrapper_with_id("post_title_input")
  it_should_have_label_with_text(/Title/)
  it_should_have_label_for("post_title")
  it_should_have_input_with_id("post_title")
  it_should_have_input_with_type(:text)
  it_should_have_input_with_name("post[title]")
  it_should_have_maxlength_matching_column_limit
  it_should_use_default_text_field_size_for_columns_longer_than_default_text_field_size(:string)
  it_should_use_column_size_for_columns_shorter_than_default_text_field_size(:string)
  it_should_use_default_text_field_size_when_method_has_no_database_column(:string)
  it_should_apply_custom_input_attributes_when_input_html_provided(:string)
  it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
  it_should_apply_error_logic_for_input_type(:string)
  
  describe "when no object is provided" do
    before do
      semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:title, :as => :string))
      end
    end
    
    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("project_title")
    it_should_have_input_with_id("project_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("project[title]")
  end
  
end

