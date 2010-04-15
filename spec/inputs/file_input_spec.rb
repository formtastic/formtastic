# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'file input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:body, :as => :file))
    end
  end

  it_should_have_input_wrapper_with_class("file")
  it_should_have_input_wrapper_with_id("post_body_input")
  it_should_have_label_with_text(/Body/)
  it_should_have_label_for("post_body")
  it_should_have_input_with_id("post_body")
  it_should_have_input_with_name("post[body]")
  it_should_apply_error_logic_for_input_type(:file)

  it 'should use input_html to style inputs' do
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:title, :as => :file, :input_html => { :class => 'myclass' }))
    end
    output_buffer.should have_tag("form li input.myclass")
  end

end

