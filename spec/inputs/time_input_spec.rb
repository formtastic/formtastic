# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'time input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:publish_at, :as => :time))
    end
  end
   
  it_should_have_input_wrapper_with_class("time")
  it_should_have_input_wrapper_with_id("post_publish_at_input")
  it_should_have_a_nested_fieldset
  it_should_apply_error_logic_for_input_type(:time)

  it 'should have a legend - classified as a label - containing the label text inside the fieldset' do
    output_buffer.should have_tag('form li.time fieldset legend.label', /Publish at/)
  end

  it 'should have an ordered list of two items inside the fieldset' do
    output_buffer.should have_tag('form li.time fieldset ol')
    output_buffer.should have_tag('form li.time fieldset ol li', :count => 2)
  end

  it 'should have five labels for hour and minute' do
    output_buffer.should have_tag('form li.time fieldset ol li label', :count => 2)
    output_buffer.should have_tag('form li.time fieldset ol li label', /hour/i)
    output_buffer.should have_tag('form li.time fieldset ol li label', /minute/i)
  end

  it 'should have two selects for hour and minute' do
    output_buffer.should have_tag('form li.time fieldset ol li', :count => 2)
  end

end

