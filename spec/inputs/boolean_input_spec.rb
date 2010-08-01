# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'boolean input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean))
    end
  end
    
  it_should_have_input_wrapper_with_class("boolean")
  it_should_have_input_wrapper_with_id("post_allow_comments_input")
  it_should_apply_error_logic_for_input_type(:boolean)

  it 'should generate a label containing the input' do
    output_buffer.should have_tag('form li label', :count => 1)
    output_buffer.should have_tag('form li label[@for="post_allow_comments"]')
    output_buffer.should have_tag('form li label', /Allow comments/)
    output_buffer.should have_tag('form li label input[@type="checkbox"]')
  end

  it 'should generate a checkbox input' do
    output_buffer.should have_tag('form li label input')
    output_buffer.should have_tag('form li label input#post_allow_comments')
    output_buffer.should have_tag('form li label input[@type="checkbox"]')
    output_buffer.should have_tag('form li label input[@name="post[allow_comments]"]')
    output_buffer.should have_tag('form li label input[@type="checkbox"][@value="1"]')
  end

  it 'should allow checked and unchecked values to be sent' do
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'checked', :unchecked_value => 'unchecked'))
    end

    output_buffer.should have_tag('form li label input[@type="checkbox"][@value="checked"]:not([@unchecked_value][@checked_value])')
    output_buffer.should have_tag('form li label input[@type="hidden"][@value="unchecked"]')
  end

  it 'should generate a label and a checkbox even if no object is given' do
    semantic_form_for(:project, :url => 'http://test.host') do |builder|
      concat(builder.input(:allow_comments, :as => :boolean))
    end

    output_buffer.should have_tag('form li label[@for="project_allow_comments"]')
    output_buffer.should have_tag('form li label', /Allow comments/)
    output_buffer.should have_tag('form li label input[@type="checkbox"]')

    output_buffer.should have_tag('form li label input#project_allow_comments')
    output_buffer.should have_tag('form li label input[@type="checkbox"]')
    output_buffer.should have_tag('form li label input[@name="project[allow_comments]"]')
  end

  describe 'when :selected is set' do
    before do
      @output_buffer = ''
    end

    describe "not selected" do
      before do
        @new_post.stub!(:allow_comments).and_return(true)

        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:allow_comments, :as => :boolean, :selected => false))
          end
        end
      end

      it 'should not be selected' do
        output_buffer.should_not have_tag("form li label input[@type='checkbox'][@checked='checked']")
      end
    end

    describe "selected" do
      before do
        @new_post.stub!(:allow_comments).and_return(false)
        
        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:allow_comments, :as => :boolean, :selected => true))
          end
        end
      end

      it 'should be selected' do
        output_buffer.should have_tag("form li label input[@type='checkbox'][@checked='checked']")
      end
    end
  end

end
