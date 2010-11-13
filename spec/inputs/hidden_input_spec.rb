# encoding: utf-8
require 'spec_helper'

describe 'hidden input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything

    @form = semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden))
      concat(builder.input(:author_id, :as => :hidden, :value => 99))
      concat(builder.input(:published, :as => :hidden, :input_html => {:value => true}))
      concat(builder.input(:reviewer, :as => :hidden, :input_html => {:class => 'new_post_reviewer', :id => 'new_post_reviewer'}))
      concat(builder.input(:author, :as => :hidden, :value => 'direct_value', :input_html => {:value => "formtastic_value"}))
    end
  end

  it_should_have_input_wrapper_with_class("hidden")
  it_should_have_input_wrapper_with_id("post_secret_input")
  it_should_not_have_a_label

  it "should generate a input field" do
    output_buffer.concat(@form) if Formtastic::Util.rails3?
    output_buffer.should have_tag("form li input#post_secret")
    output_buffer.should have_tag("form li input#post_secret[@type=\"hidden\"]")
    output_buffer.should have_tag("form li input#post_secret[@name=\"post[secret]\"]")
  end

  it "should pass any explicitly specified value - using :value" do
    output_buffer.concat(@form) if Formtastic::Util.rails3?
    output_buffer.should have_tag("form li input#post_author_id[@type=\"hidden\"][@value=\"99\"]")
  end

  # Handle Formtastic :input_html options for consistency.
  it "should pass any explicitly specified value - using :input_html options" do
    output_buffer.concat(@form) if Formtastic::Util.rails3?
    output_buffer.should have_tag("form li input#post_published[@type=\"hidden\"][@value=\"true\"]")
  end

  it "should pass any option specified using :input_html" do
    output_buffer.concat(@form) if Formtastic::Util.rails3?
    output_buffer.should have_tag("form li input#new_post_reviewer[@type=\"hidden\"][@class=\"new_post_reviewer\"]")
  end

  it "should prefer :input_html over directly supplied options" do
    output_buffer.concat(@form) if Formtastic::Util.rails3?
    output_buffer.should have_tag("form li input#post_author[@type=\"hidden\"][@value=\"formtastic_value\"]")
  end

  it "should not render inline errors" do
    @errors = mock('errors')
    @errors.stub!(:[]).with(:secret).and_return(["foo", "bah"])
    @new_post.stub!(:errors).and_return(@errors)

    form = semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden))
    end

    output_buffer.concat(form) if Formtastic::Util.rails3?
    output_buffer.should_not have_tag("form li p.inline-errors")
    output_buffer.should_not have_tag("form li ul.errors")
  end

  it "should not render inline hints" do
    form = semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden, :hint => "all your base are belong to use"))
    end

    output_buffer.concat(form) if Formtastic::Util.rails3?
    output_buffer.should_not have_tag("form li p.inline-hints")
    output_buffer.should_not have_tag("form li ul.hints")
  end

  describe "when namespace is provided" do

    before do
      @output_buffer = ''
      mock_everything

      @form = semantic_form_for(@new_post, :namespace => 'context2') do |builder|
        concat(builder.input(:secret, :as => :hidden))
        concat(builder.input(:author_id, :as => :hidden, :value => 99))
        concat(builder.input(:published, :as => :hidden, :input_html => {:value => true}))
        concat(builder.input(:reviewer, :as => :hidden, :input_html => {:class => 'new_post_reviewer', :id => 'new_post_reviewer'}))
        concat(builder.input(:author, :as => :hidden, :value => 'direct_value', :input_html => {:value => "formtastic_value"}))
      end
    end

    attributes_to_check = [:secret, :author_id, :published, :reviewer, :author]
    attributes_to_check.each do |a|
      it_should_have_input_wrapper_with_id("context2_post_#{a}_input")
    end

    (attributes_to_check - [:reviewer]).each do |a|
      it_should_have_input_with_id("context2_post_#{a}")
    end

  end

end

