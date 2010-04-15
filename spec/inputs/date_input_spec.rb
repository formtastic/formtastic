# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'date input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end
  
  describe "general" do
    
    before do
      output_buffer.replace ''
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :date))
      end
    end

    it_should_have_input_wrapper_with_class("date")
    it_should_have_input_wrapper_with_id("post_publish_at_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:date)
    
    it 'should have a legend and label with the label text inside the fieldset' do
      output_buffer.should have_tag('form li.date fieldset legend.label label', /Publish at/)
    end
    
    it 'should associate the legend label with the first select' do
      output_buffer.should have_tag('form li.date fieldset legend.label')
      output_buffer.should have_tag('form li.date fieldset legend.label label')
      output_buffer.should have_tag('form li.date fieldset legend.label label[@for]')
      output_buffer.should have_tag('form li.date fieldset legend.label label[@for="post_publish_at_1i"]')
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
  end
    
  describe ':selected option' do
    
    describe "when the object has a value" do
      it "should select the object value (ignoring :selected)" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => Time.mktime(2012))
        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:created_at, :as => :date, :selected => Time.mktime(1999)))
          end
        end
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@selected]", :count => 1)
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@value='2012'][@selected]", :count => 1)
      end
    end
    
    describe 'when the object has no value' do
      it "should select the :selected if provided as a Date" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => nil)
        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:created_at, :as => :date, :selected => Date.new(1999)))
          end
        end
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@selected]", :count => 1)
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@value='1999'][@selected]", :count => 1)
      end
      
      it "should select the :selected if provided as a Time" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => nil)
        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:created_at, :as => :date, :selected => Time.mktime(1999)))
          end
        end
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@selected]", :count => 1)
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@value='1999'][@selected]", :count => 1)
      end
      
      it "should not select an option if the :selected is provided as nil" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => nil)
        with_deprecation_silenced do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:created_at, :as => :date, :selected => nil))
          end
        end
        output_buffer.should_not have_tag("form li ol li select#post_created_at_1i option[@selected]")
      end
      
      it "should select Time.now if a :selected is not provided" do
        output_buffer.replace ''
        @new_post.stub!(:created_at => nil)
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :date))
        end
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@selected]", :count => 1)
        output_buffer.should have_tag("form li ol li select#post_created_at_1i option[@value='#{Time.now.year}'][@selected]", :count => 1)
        
      end
    end
    
  end

  describe ':labels option' do
    fields = [:year, :month, :day]
    fields.each do |field|
      it "should replace the #{field} label with the specified text if :labels[:#{field}] is set" do
        output_buffer.replace ''
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :date, :labels => { field => "another #{field} label" }))
        end
        output_buffer.should have_tag('form li.date fieldset ol li label', :count => fields.length)
        fields.each do |f|
          output_buffer.should have_tag('form li.date fieldset ol li label', f == field ? /another #{f} label/i : /#{f}/i)
        end
      end

      it "should not display the label for the #{field} field when :labels[:#{field}] is blank" do
        output_buffer.replace ''
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :date, :labels => { field => "" }))
        end
        output_buffer.should have_tag('form li.date fieldset ol li label', :count => fields.length-1)
        fields.each do |f|
          output_buffer.should have_tag('form li.date fieldset ol li label', /#{f}/i) unless field == f
        end
      end
    end
  end

  it 'should warn about :selected deprecation' do
    with_deprecation_silenced do
      ::ActiveSupport::Deprecation.should_receive(:warn).any_number_of_times
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:created_at, :as => :date, :selected => Date.new(1999)))
      end
    end
  end
  
end
