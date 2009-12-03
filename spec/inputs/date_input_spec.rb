# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'date input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:publish_at, :as => :date))
    end
  end

  it_should_have_input_wrapper_with_class("date")
  it_should_have_input_wrapper_with_id("post_publish_at_input")
  it_should_have_a_nested_fieldset
  it_should_apply_error_logic_for_input_type(:date)
  
  it 'should have a legend - classified as a label - containing the label text inside the fieldset' do
    output_buffer.should have_tag('form li.date fieldset legend.label', /Publish at/)
  end

  it 'should have an ordered list of three items inside the fieldset' do
    output_buffer.should have_tag('form li.date fieldset ol')
    output_buffer.should have_tag('form li.date fieldset ol li', :count => 3)
  end

  it 'should have three labels for year, month and day' do
    output_buffer.should have_tag('form li.date fieldset ol li label', :count => 3)
    output_buffer.should have_tag('form li.date fieldset ol li label', /year/i)
    output_buffer.should have_tag('form li.date fieldset ol li label', /month/i)
    output_buffer.should have_tag('form li.date fieldset ol li label', /day/i)
  end

  it 'should have three selects for year, month and day' do
    output_buffer.should have_tag('form li.date fieldset ol li select', :count => 3)
  end

  it_should_select_existing_datetime_else_current(:year, :month, :day)
  it_should_select_explicit_default_value_if_set(:year, :month, :day)

end
