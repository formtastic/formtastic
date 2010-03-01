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
  
  describe 'when :selected is set' do
    before do
      @output_buffer = ''
    end

    # Note: Not possible to override default selected value for time_zone input
    # without overriding Rails time_zone_select. This Rails helper works "a bit different". =/
    #
    # describe "no selected items" do
    #   before do
    #     @new_post.stub!(:time_zone).and_return('Stockholm')
    # 
    #     semantic_form_for(@new_post) do |builder|
    #       concat(builder.input(:time_zone, :as => :time_zone, :selected => nil))
    #     end
    #   end
    # 
    #   it 'should not have any selected item(s)' do
    #     output_buffer.should_not have_tag("form li select option[@selected='selected']")
    #   end
    # end

    describe "single selected item" do
      before do
        # Note: See above...only works for the "attribute is nil" case.
        # @new_post.stub!(:time_zone).and_return('Stockholm')
        @new_post.stub!(:time_zone).and_return(nil)

        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:time_zone, :as => :time_zone, :selected => 'Melbourne'))
          end
        end
      end

      it 'should have a selected item; the specified one' do
        output_buffer.should have_tag("form li select option[@selected='selected']", :count => 1)
        output_buffer.should have_tag("form li select option[@selected='selected']", /Melbourne/i)
        output_buffer.should have_tag("form li select option[@selected='selected'][@value='Melbourne']")
      end
    end

  end

end
