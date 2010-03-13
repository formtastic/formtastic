# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'time input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end
  
  describe "general" do
    before do
      output_buffer.replace ''
    end

    describe "without seconds" do
      before do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :time))
        end
      end
     
      it_should_have_input_wrapper_with_class("time")
      it_should_have_input_wrapper_with_id("post_publish_at_input")
      it_should_have_a_nested_fieldset
      it_should_apply_error_logic_for_input_type(:time)
    
      it 'should have a legend and label with the label text inside the fieldset' do
        output_buffer.should have_tag('form li.time fieldset legend.label label', /Publish at/)
      end
    
      it 'should associate the legend label with the first select' do
        output_buffer.should have_tag('form li.time fieldset legend.label label[@for="post_publish_at_1i"]')
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

    describe "with seconds" do
      before do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :time, :include_seconds => true))
        end
      end
    
      it 'should have five labels for hour and minute' do
        output_buffer.should have_tag('form li.time fieldset ol li label', :count => 3)
        output_buffer.should have_tag('form li.time fieldset ol li label', /hour/i)
        output_buffer.should have_tag('form li.time fieldset ol li label', /minute/i)
        output_buffer.should have_tag('form li.time fieldset ol li label', /second/i)
      end

      it 'should have three selects for hour, minute and seconds' do
        output_buffer.should have_tag('form li.time fieldset ol li', :count => 3)
      end

      it 'should generate a sanitized label and matching ids for attribute' do
        4.upto(6) do |i|
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_publish_at_#{i}i']")
          output_buffer.should have_tag("form li fieldset ol li #post_publish_at_#{i}i")
        end
      end
    end
  end

  describe ':selected option' do
    
    describe "when the object has a value" do
      it "should select the object value (ignoring :selected)" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => Time.mktime(2012, 11, 30, 21, 45))
        with_deprecation_silenced do 
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:created_at, :as => :time, :selected => Time.mktime(1999, 12, 31, 22, 59)))
          end
        end
        output_buffer.should have_tag("form li ol li select#post_created_at_4i option[@selected]", :count => 1)
        output_buffer.should have_tag("form li ol li select#post_created_at_4i option[@value='21'][@selected]", :count => 1)
      end
    end
    
    describe 'when the object has no value' do
      it "should select the :selected if provided as a Time" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => nil)
        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:created_at, :as => :time, :selected => Time.mktime(1999, 12, 31, 22, 59)))
          end
        end
        output_buffer.should have_tag("form li ol li select#post_created_at_4i option[@selected]", :count => 1)
        output_buffer.should have_tag("form li ol li select#post_created_at_4i option[@value='22'][@selected]", :count => 1)
      end
      
      it "should not select an option if the :selected is provided as nil" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => nil)
        with_deprecation_silenced do 
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:created_at, :as => :time, :selected => nil))
          end
        end
        output_buffer.should_not have_tag("form li ol li select#post_created_at_4i option[@selected]")
      end
      
      it "should select Time.now if a :selected is not provided" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => nil)
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time))
        end
        output_buffer.should have_tag("form li ol li select#post_created_at_4i option[@selected]", :count => 1)
        output_buffer.should have_tag("form li ol li select#post_created_at_4i option[@value='#{Time.now.hour.to_s.rjust(2,'0')}'][@selected]", :count => 1)
      end
    end
    
  end
  
  describe ':labels option' do
    fields = [:hour, :minute, :second]
    fields.each do |field|
      it "should replace the #{field} label with the specified text if :labels[:#{field}] is set" do
        output_buffer.replace ''
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time, :include_seconds => true, :labels => { field => "another #{field} label" }))
        end
        output_buffer.should have_tag('form li.time fieldset ol li label', :count => fields.length)
        fields.each do |f|
          output_buffer.should have_tag('form li.time fieldset ol li label', f == field ? /another #{f} label/i : /#{f}/i)
        end
      end
  
      it "should not display the label for the #{field} field when :labels[:#{field}] is blank" do
        output_buffer.replace ''
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time, :include_seconds => true, :labels => { field => "" }))
        end
        output_buffer.should have_tag('form li.time fieldset ol li label', :count => fields.length-1)
        fields.each do |f|
          output_buffer.should have_tag('form li.time fieldset ol li label', /#{f}/i) unless field == f
        end
      end
    end
  end
  
  it 'should warn about :selected deprecation' do
    with_deprecation_silenced do
      ::ActiveSupport::Deprecation.should_receive(:warn).any_number_of_times
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:created_at, :as => :time, :selected => Time.mktime(1999)))
      end
    end
  end
  
end
