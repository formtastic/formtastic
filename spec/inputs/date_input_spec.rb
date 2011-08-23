# encoding: utf-8
require 'spec_helper'

describe 'date input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe "general" do

    before do
      output_buffer.replace ''
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :date, :order => [:year, :month, :day]))
      end)
    end

    it_should_have_input_wrapper_with_class("date")
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_id("post_publish_at_input")
    it_should_have_a_nested_fieldset
    it_should_have_a_nested_fieldset_with_class('fragments')
    it_should_have_a_nested_ordered_list_with_class('fragments-group')
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
      output_buffer.should have_tag('form li.date fieldset ol.fragments-group')
      output_buffer.should have_tag('form li.date fieldset ol li.fragment', :count => 3)
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

  describe "when namespace is provided" do

    before do
      output_buffer.replace ''
      concat(semantic_form_for(@new_post, :namespace => "context2") do |builder|
        concat(builder.input(:publish_at, :as => :date, :order => [:year, :month, :day]))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_post_publish_at_input")
    it_should_have_select_with_id("context2_post_publish_at_1i")
    it_should_have_select_with_id("context2_post_publish_at_2i")
    it_should_have_select_with_id("context2_post_publish_at_3i")

  end

  describe ':labels option' do
    fields = [:year, :month, :day]
    fields.each do |field|
      it "should replace the #{field} label with the specified text if :labels[:#{field}] is set" do
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :date, :labels => { field => "another #{field} label" }))
        end)
        output_buffer.should have_tag('form li.date fieldset ol li label', :count => fields.length)
        fields.each do |f|
          output_buffer.should have_tag('form li.date fieldset ol li label', f == field ? /another #{f} label/i : /#{f}/i)
        end
      end

      it "should not display the label for the #{field} field when :labels[:#{field}] is blank" do
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :date, :labels => { field => "" }))
        end)
        output_buffer.should have_tag('form li.date fieldset ol li label', :count => fields.length-1)
        fields.each do |f|
          output_buffer.should have_tag('form li.date fieldset ol li label', /#{f}/i) unless field == f
        end
      end
      
      it "should not display the label for the #{field} field when :labels[:#{field}] is false" do
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :date, :labels => { field => false }))
        end)
        output_buffer.should have_tag('form li.date fieldset ol li label', :count => fields.length-1)
        fields.each do |f|
          output_buffer.should have_tag('form li.date fieldset ol li label', /#{f}/i) unless field == f
        end
      end
      
      it "should not render unsafe HTML when :labels[:#{field}] is false" do 
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time, :include_seconds => true, :labels => { field => false }))
        end)
        output_buffer.should_not include("&gt;")
      end
      
    end
  end
  
  describe "when required" do
    it "should add the required attribute to the input's html options" do
      with_config :use_required_attribute, true do 
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :date, :required => true))
        end)
        output_buffer.should have_tag("select[@required]", :count => 3)
      end
    end
  end
  
end
