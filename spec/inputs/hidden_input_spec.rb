# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'hidden input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden))
    end
  end

  it_should_have_input_wrapper_with_class("hidden")
  it_should_have_input_wrapper_with_id("post_secret_input")
  it_should_not_have_a_label

  it "should generate a input field" do
    output_buffer.should have_tag("form li input#post_secret")
    output_buffer.should have_tag("form li input[@type=\"hidden\"]")
    output_buffer.should have_tag("form li input[@name=\"post[secret]\"]")
  end
  
  it "should not render inline errors" do
    @errors = mock('errors')
    @errors.stub!(:[]).with(:secret).and_return(["foo", "bah"])
    @new_post.stub!(:errors).and_return(@errors)
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden))
    end
    
    output_buffer.should_not have_tag("form li p.inline-errors")
    output_buffer.should_not have_tag("form li ul.errors")
  end
    
end

