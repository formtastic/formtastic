# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'hidden input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden))
      concat(builder.input(:author_id, :as => :hidden, :value => 99))
      concat(builder.input(:published, :as => :hidden, :input_html => {:value => true}))
    end
  end

  it_should_have_input_wrapper_with_class("hidden")
  it_should_have_input_wrapper_with_id("post_secret_input")
  it_should_not_have_a_label

  it "should generate a input field" do
    output_buffer.should have_tag("form li input#post_secret")
    output_buffer.should have_tag("form li input#post_secret[@type=\"hidden\"]")
    output_buffer.should have_tag("form li input#post_secret[@name=\"post[secret]\"]")
  end
  
  it "should pass any explicitly specified value - using :value" do
    output_buffer.should have_tag("form li input#post_author_id[@type=\"hidden\"][@value=\"99\"]")
  end
  
  # Handle Formtastic :input_html options for consistency.
  it "should pass any explicitly specified value - using :input_html options" do
    output_buffer.should have_tag("form li input#post_published[@type=\"hidden\"][@value=\"true\"]")
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

