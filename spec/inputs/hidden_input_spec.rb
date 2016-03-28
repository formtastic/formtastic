# encoding: utf-8
require 'spec_helper'

RSpec.describe 'hidden input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
    
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden))
      concat(builder.input(:published, :as => :hidden, :input_html => {:value => true}))
      concat(builder.input(:reviewer, :as => :hidden, :input_html => {:class => 'new_post_reviewer', :id => 'new_post_reviewer'}))
    end)
  end

  it_should_have_input_wrapper_with_class("hidden")
  it_should_have_input_wrapper_with_class(:input)
  it_should_have_input_wrapper_with_id("post_secret_input")
  it_should_not_have_a_label

  it "should generate a input field" do
    expect(output_buffer).to have_tag("form li input#post_secret")
    expect(output_buffer).to have_tag("form li input#post_secret[@type=\"hidden\"]")
    expect(output_buffer).to have_tag("form li input#post_secret[@name=\"post[secret]\"]")
  end

  it "should get value from the object" do
    expect(output_buffer).to have_tag("form li input#post_secret[@type=\"hidden\"][@value=\"1\"]")
  end
  
  it "should pass any explicitly specified value - using :input_html options" do
    expect(output_buffer).to have_tag("form li input#post_published[@type=\"hidden\"][@value=\"true\"]")
  end

  it "should pass any option specified using :input_html" do
    expect(output_buffer).to have_tag("form li input#new_post_reviewer[@type=\"hidden\"][@class=\"new_post_reviewer\"]")
  end

  it "should not render inline errors" do
    @errors = double('errors')
    allow(@errors).to receive(:[]).with(errors_matcher(:secret)).and_return(["foo", "bah"])
    allow(@new_post).to receive(:errors).and_return(@errors)

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden))
    end)

    expect(output_buffer).not_to have_tag("form li p.inline-errors")
    expect(output_buffer).not_to have_tag("form li ul.errors")
  end

  it "should not render inline hints" do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:secret, :as => :hidden, :hint => "all your base are belong to use"))
    end)

    expect(output_buffer).not_to have_tag("form li p.inline-hints")
    expect(output_buffer).not_to have_tag("form li ul.hints")
  end

  describe "when namespace is provided" do

    before do
      @output_buffer = ''
      mock_everything
      
      concat(semantic_form_for(@new_post, :namespace => 'context2') do |builder|
        concat(builder.input(:secret, :as => :hidden))
        concat(builder.input(:published, :as => :hidden, :input_html => {:value => true}))
        concat(builder.input(:reviewer, :as => :hidden, :input_html => {:class => 'new_post_reviewer', :id => 'new_post_reviewer'}))
      end)
    end

    attributes_to_check = [:secret, :published, :reviewer]
    attributes_to_check.each do |a|
      it_should_have_input_wrapper_with_id("context2_post_#{a}_input")
    end

    (attributes_to_check - [:reviewer]).each do |a|
      it_should_have_input_with_id("context2_post_#{a}")
    end

  end
  
  describe "when index is provided" do

    before do
      @output_buffer = ''
      mock_everything

      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.fields_for(:author, :index => 3) do |author|
          concat(author.input(:name, :as => :hidden))
        end)
      end)
    end
    
    it 'should index the id of the wrapper' do
      expect(output_buffer).to have_tag("li#post_author_attributes_3_name_input")
    end
    
    it 'should index the id of the select tag' do
      expect(output_buffer).to have_tag("input#post_author_attributes_3_name")
    end
    
    it 'should index the name of the select tag' do
      expect(output_buffer).to have_tag("input[@name='post[author_attributes][3][name]']")
    end
    
  end
  
  
  context "when required" do
    it "should not add the required attribute to the input's html options" do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :hidden, :required => true))
      end)
      expect(output_buffer).not_to have_tag("input[@required]")
    end
  end

  context "when :autofocus is provided in :input_html" do
    it "should not add the autofocus attribute to the input's html options" do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :hidden, :input_html => {:autofocus => true}))
      end)
      expect(output_buffer).not_to have_tag("input[@autofocus]")
    end
  end

end

