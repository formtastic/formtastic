# encoding: utf-8
require 'spec_helper'

RSpec.describe 'boolean input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'generic' do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:allow_comments, :as => :boolean))
      end)
    end
    
    it_should_have_input_wrapper_with_class("boolean")
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_id("post_allow_comments_input")
    it_should_apply_error_logic_for_input_type(:boolean)
  
    it 'should generate a label containing the input' do
    expect(output_buffer).not_to have_tag('label.label')
    expect(output_buffer).to have_tag('form li label', :count => 1)
    expect(output_buffer).to have_tag('form li label[@for="post_allow_comments"]')
    expect(output_buffer).to have_tag('form li label', :text => /Allow comments/)
    expect(output_buffer).to have_tag('form li label input[@type="checkbox"]', :count => 1)
    expect(output_buffer).to have_tag('form li input[@type="hidden"]', :count => 1)
    expect(output_buffer).not_to have_tag('form li label input[@type="hidden"]', :count => 1) # invalid HTML5
    end
  
    it 'should not add a "name" attribute to the label' do
      expect(output_buffer).not_to have_tag('form li label[@name]')
    end
  
    it 'should generate a checkbox input' do
      expect(output_buffer).to have_tag('form li label input')
      expect(output_buffer).to have_tag('form li label input#post_allow_comments')
      expect(output_buffer).to have_tag('form li label input[@type="checkbox"]')
      expect(output_buffer).to have_tag('form li label input[@name="post[allow_comments]"]')
      expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="1"]')
    end
  
    it 'should generate a checked input if object.method returns true' do
      expect(output_buffer).to have_tag('form li label input[@checked="checked"]')
      expect(output_buffer).to have_tag('form li input[@name="post[allow_comments]"]', :count => 2)
      expect(output_buffer).to have_tag('form li input#post_allow_comments', :count => 1)
    end
  end

  it 'should generate a checked input if :input_html is passed :checked => checked' do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:answer_comments, :as => :boolean, :input_html => {:checked => 'checked'}))
    end)
    expect(output_buffer).to have_tag('form li label input[@checked="checked"]')
  end

  it 'should name the hidden input with the :name html_option' do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:answer_comments, :as => :boolean, :input_html => { :name => "foo" }))
    end)

    expect(output_buffer).to have_tag('form li input[@type="checkbox"][@name="foo"]', :count => 1)
    expect(output_buffer).to have_tag('form li input[@type="hidden"][@name="foo"]', :count => 1)
  end

  it 'should name the hidden input with the :name html_option' do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:answer_comments, :as => :boolean, :input_html => { :name => "foo" }))
    end)

    expect(output_buffer).to have_tag('form li input[@type="checkbox"][@name="foo"]', :count => 1)
    expect(output_buffer).to have_tag('form li input[@type="hidden"][@name="foo"]', :count => 1)
  end

  it "should generate a disabled input and hidden input if :input_html is passed :disabled => 'disabled' " do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :input_html => {:disabled => 'disabled'}))
    end)
    expect(output_buffer).to have_tag('form li label input[@disabled="disabled"]', :count => 1)
    expect(output_buffer).to have_tag('form li input[@type="hidden"][@disabled="disabled"]', :count => 1)
  end

  it 'should generate an input[id] with matching label[for] when id passed in :input_html' do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :input_html => {:id => 'custom_id'}))
    end)
    expect(output_buffer).to have_tag('form li label input[@id="custom_id"]')
    expect(output_buffer).to have_tag('form li label[@for="custom_id"]')
  end

  it 'should allow checked and unchecked values to be sent' do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'checked', :unchecked_value => 'unchecked'))
    end)
    expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="checked"]:not([@unchecked_value][@checked_value])')
    expect(output_buffer).to have_tag('form li input[@type="hidden"][@value="unchecked"]')
    expect(output_buffer).not_to have_tag('form li label input[@type="hidden"]') # invalid HTML5
  end

  it 'should generate a checked input if object.method returns checked value' do
    allow(@new_post).to receive(:allow_comments).and_return('yes')

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'yes', :unchecked_value => 'no'))
    end)

    expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="yes"][@checked="checked"]')
  end

  it 'should not generate a checked input if object.method returns unchecked value' do
    allow(@new_post).to receive(:allow_comments).and_return('no')

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'yes', :unchecked_value => 'no'))
    end)

    expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="yes"]:not([@checked])')
  end

  it 'should generate a checked input if object.method returns checked value' do
    allow(@new_post).to receive(:allow_comments).and_return('yes')

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'yes', :unchecked_value => 'no'))
    end)

    expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="yes"][@checked="checked"]')
  end

  it 'should generate a checked input for boolean database values compared to string checked values' do
    allow(@new_post).to receive(:foo).and_return(1)

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:foo, :as => :boolean))
    end)

    expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="1"][@checked="checked"]')
  end

  it 'should generate a checked input if object.method returns checked value when inverted' do
    allow(@new_post).to receive(:allow_comments).and_return(0)

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 0, :unchecked_value => 1))
    end)

    expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="0"][@checked="checked"]')
  end

  it 'should not generate a checked input if object.method returns unchecked value' do
    allow(@new_post).to receive(:allow_comments).and_return('no')

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'yes', :unchecked_value => 'no'))
    end)

    expect(output_buffer).to have_tag('form li label input[@type="checkbox"][@value="yes"]:not([@checked])')
  end

  it 'should generate a label and a checkbox even if no object is given' do
    concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
      concat(builder.input(:allow_comments, :as => :boolean))
    end)

    expect(output_buffer).to have_tag('form li label[@for="project_allow_comments"]')
    expect(output_buffer).to have_tag('form li label', :text => /Allow comments/)
    expect(output_buffer).to have_tag('form li label input[@type="checkbox"]')

    expect(output_buffer).to have_tag('form li label input#project_allow_comments')
    expect(output_buffer).to have_tag('form li label input[@type="checkbox"]')
    expect(output_buffer).to have_tag('form li label input[@name="project[allow_comments]"]')
  end
  
  it 'should not pass input_html options down to the label html' do
    concat(semantic_form_for(@new_post) do |builder|
      builder.input(:title, :as => :boolean, :input_html => { :tabindex => 2, :x => "X" })
    end)
    expect(output_buffer).not_to have_tag('label[tabindex]')
    expect(output_buffer).not_to have_tag('label[x]')
  end

  context "when required" do
    
    it "should add the required attribute to the input's html options" do
      with_config :use_required_attribute, true do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :boolean, :required => true))
        end)
        expect(output_buffer).to have_tag("input[@required]")
      end
    end
      
    it "should not add the required attribute to the boolean fields input's html options" do
      with_config :use_required_attribute, true do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :boolean))
        end)
        expect(output_buffer).not_to have_tag("input[@required]")
      end
    end
    
  end

  describe "when namespace is provided" do

    before do
      @output_buffer = ''
      mock_everything

      concat(semantic_form_for(@new_post, :namespace => "context2") do |builder|
        concat(builder.input(:allow_comments, :as => :boolean))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_post_allow_comments_input")
    it_should_have_an_inline_label_for("context2_post_allow_comments")

  end
  
  describe "when index is provided" do

    before do
      @output_buffer = ''
      mock_everything

      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.fields_for(:author, :index => 3) do |author|
          concat(author.input(:name, :as => :boolean))
        end)
      end)
    end
    
    it 'should index the id of the wrapper' do
      expect(output_buffer).to have_tag("li#post_author_attributes_3_name_input")
    end
    
    it 'should index the id of the input tag' do
      expect(output_buffer).to have_tag("input#post_author_attributes_3_name")
    end
    
    it 'should index the name of the hidden input' do
      expect(output_buffer).to have_tag("input[@type='hidden'][@name='post[author_attributes][3][name]']")
    end

    it 'should index the name of the checkbox input' do
      expect(output_buffer).to have_tag("input[@type='checkbox'][@name='post[author_attributes][3][name]']")
    end
    
  end
end
