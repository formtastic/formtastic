# encoding: utf-8
require 'spec_helper'

describe 'boolean input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything

    @form = semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean))
    end
  end

  it_should_have_input_wrapper_with_class("boolean")
  it_should_have_input_wrapper_with_id("post_allow_comments_input")
  it_should_apply_error_logic_for_input_type(:boolean)

  it 'should generate a label containing the input' do
    output_buffer.concat(@form) if Formtastic::Util.rails3?
    output_buffer.should have_tag('form li label', :count => 1)
    output_buffer.should have_tag('form li label[@for="post_allow_comments"]')
    output_buffer.should have_tag('form li label', /Allow comments/)
    output_buffer.should have_tag('form li label input[@type="checkbox"]', :count => 1)
    output_buffer.should have_tag('form li input[@type="hidden"]', :count => 1)
    output_buffer.should_not have_tag('form li label input[@type="hidden"]', :count => 1) # invalid HTML5
  end

  it 'should generate a checkbox input' do
    output_buffer.concat(@form) if Formtastic::Util.rails3?
    output_buffer.should have_tag('form li label input')
    output_buffer.should have_tag('form li label input#post_allow_comments')
    output_buffer.should have_tag('form li label input[@type="checkbox"]')
    output_buffer.should have_tag('form li label input[@name="post[allow_comments]"]')
    output_buffer.should have_tag('form li label input[@type="checkbox"][@value="1"]')
  end

  it 'should allow checked and unchecked values to be sent' do
    form = semantic_form_for(@new_post) do |builder|
      concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'checked', :unchecked_value => 'unchecked'))
    end

    output_buffer.concat(form) if Formtastic::Util.rails3?
    output_buffer.should have_tag('form li label input[@type="checkbox"][@value="checked"]:not([@unchecked_value][@checked_value])')
    output_buffer.should have_tag('form li input[@type="hidden"][@value="unchecked"]')
    output_buffer.should_not have_tag('form li label input[@type="hidden"]') # invalid HTML5
  end

  it 'should generate a label and a checkbox even if no object is given' do
    form = semantic_form_for(:project, :url => 'http://test.host') do |builder|
      concat(builder.input(:allow_comments, :as => :boolean))
    end

    output_buffer.concat(form) if Formtastic::Util.rails3?

    output_buffer.should have_tag('form li label[@for="project_allow_comments"]')
    output_buffer.should have_tag('form li label', /Allow comments/)
    output_buffer.should have_tag('form li label input[@type="checkbox"]')

    output_buffer.should have_tag('form li label input#project_allow_comments')
    output_buffer.should have_tag('form li label input[@type="checkbox"]')
    output_buffer.should have_tag('form li label input[@name="project[allow_comments]"]')
  end

end
