# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'text input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:body, :as => :text))
    end
  end
    
  it_should_have_input_wrapper_with_class("text")
  it_should_have_input_wrapper_with_id("post_body_input")
  it_should_have_label_with_text(/Body/)
  it_should_have_label_for("post_body")
  it_should_have_textarea_with_id("post_body")
  it_should_have_textarea_with_name("post[body]")
  it_should_apply_error_logic_for_input_type(:numeric)
  
  it 'should use input_html to style inputs' do
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:title, :as => :text, :input_html => { :class => 'myclass' }))
    end
    output_buffer.should have_tag("form li textarea.myclass")
  end
    
end

