# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'time_zone input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything

    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:time_zone))
    end
  end
    
  it_should_have_input_wrapper_with_class("time_zone")
  it_should_have_input_wrapper_with_id("post_time_zone_input")
  it_should_apply_error_logic_for_input_type(:time_zone)
  
  it 'should generate a label for the input' do
    output_buffer.should have_tag('form li label')
    output_buffer.should have_tag('form li label[@for="post_time_zone"]')
    output_buffer.should have_tag('form li label', /Time zone/)
  end

  it "should generate a select" do
    output_buffer.should have_tag("form li select")
    output_buffer.should have_tag("form li select#post_time_zone")
    output_buffer.should have_tag("form li select[@name=\"post[time_zone]\"]")
  end

  it 'should use input_html to style inputs' do
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:time_zone, :input_html => { :class => 'myclass' }))
    end
    output_buffer.should have_tag("form li select.myclass")
  end

  describe 'when no object is given' do
    before(:each) do
      semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:time_zone, :as => :time_zone))
      end
    end

    it 'should generate labels' do
      output_buffer.should have_tag('form li label')
      output_buffer.should have_tag('form li label[@for="project_time_zone"]')
      output_buffer.should have_tag('form li label', /Time zone/)
    end

    it 'should generate select inputs' do
      output_buffer.should have_tag("form li select")
      output_buffer.should have_tag("form li select#project_time_zone")
      output_buffer.should have_tag("form li select[@name=\"project[time_zone]\"]")
    end
  end
end
