# encoding: utf-8
require 'spec_helper'

RSpec.describe 'time select input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe "general" do
    before do
      ::I18n.backend.reload!
      output_buffer.replace ''
    end

    describe "with :ignore_date => true" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :time_select, :ignore_date => true))
        end)
      end

      it 'should not have hidden inputs for day, month and year' do
        expect(output_buffer).not_to have_tag('input#post_publish_at_1i')
        expect(output_buffer).not_to have_tag('input#post_publish_at_2i')
        expect(output_buffer).not_to have_tag('input#post_publish_at_3i')
      end

      it 'should have an input for hour and minute' do
        expect(output_buffer).to have_tag('select#post_publish_at_4i')
        expect(output_buffer).to have_tag('select#post_publish_at_5i')
      end

    end
    
    describe "with :ignore_date => false" do
      before do
        allow(@new_post).to receive(:publish_at).and_return(Time.parse('2010-11-07'))
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :time_select, :ignore_date => false))
        end)
      end

      it 'should have a hidden input for day, month and year' do
        expect(output_buffer).to have_tag('input#post_publish_at_1i')
        expect(output_buffer).to have_tag('input#post_publish_at_2i')
        expect(output_buffer).to have_tag('input#post_publish_at_3i')
        expect(output_buffer).to have_tag('input#post_publish_at_1i[@value="2010"]')
        expect(output_buffer).to have_tag('input#post_publish_at_2i[@value="11"]')
        expect(output_buffer).to have_tag('input#post_publish_at_3i[@value="7"]')
      end

      it 'should have an select for hour and minute' do
        expect(output_buffer).to have_tag('select#post_publish_at_4i')
        expect(output_buffer).to have_tag('select#post_publish_at_5i')
      end

      it 'should associate the legend label with the hour select' do
        expect(output_buffer).to have_tag('form li.time_select fieldset legend.label label[@for="post_publish_at_4i"]')
      end

    end

    describe "without seconds" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :time_select))
        end)
      end

      it_should_have_input_wrapper_with_class("time_select")
      it_should_have_input_wrapper_with_class(:input)
      it_should_have_input_wrapper_with_id("post_publish_at_input")
      it_should_have_a_nested_fieldset
      it_should_have_a_nested_fieldset_with_class('fragments')
      it_should_have_a_nested_ordered_list_with_class('fragments-group')
      it_should_apply_error_logic_for_input_type(:time_select)

      it 'should have a legend and label with the label text inside the fieldset' do
        expect(output_buffer).to have_tag('form li.time_select fieldset legend.label label', :text => /Publish at/)
      end

      it 'should associate the legend label with the first select' do
        expect(output_buffer).to have_tag('form li.time_select fieldset legend.label label[@for="post_publish_at_4i"]')
      end

      it 'should have an ordered list of two items inside the fieldset' do
        expect(output_buffer).to have_tag('form li.time_select fieldset ol.fragments-group')
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li.fragment', :count => 2)
      end

      it 'should have five labels for hour and minute' do
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :count => 2)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => /hour/i)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => /minute/i)
      end

      it 'should have two selects for hour and minute' do
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li', :count => 2)
      end
    end

    describe "with seconds" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :time_select, :include_seconds => true))
        end)
      end

      it 'should have five labels for hour and minute' do
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :count => 3)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => /hour/i)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => /minute/i)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => /second/i)
      end

      it 'should have three selects for hour, minute and seconds' do
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li', :count => 3)
      end

      it 'should generate a sanitized label and matching ids for attribute' do
        4.upto(6) do |i|
          expect(output_buffer).to have_tag("form li fieldset ol li label[@for='post_publish_at_#{i}i']")
          expect(output_buffer).to have_tag("form li fieldset ol li #post_publish_at_#{i}i")
        end
      end
    end
  end

  describe ':labels option' do
    fields = [:hour, :minute, :second]
    fields.each do |field|
      it "should replace the #{field} label with the specified text if :labels[:#{field}] is set" do
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time_select, :include_seconds => true, :labels => { field => "another #{field} label" }))
        end)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :count => fields.length)
        fields.each do |f|
          expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => f == field ? /another #{f} label/i : /#{f}/i)
        end
      end

      it "should not display the label for the #{field} field when :labels[:#{field}] is blank" do
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time_select, :include_seconds => true, :labels => { field => "" }))
        end)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :count => fields.length-1)
        fields.each do |f|
          expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => /#{f}/i) unless field == f
        end
      end
      
      it "should not render the label when :labels[:#{field}] is false" do 
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time_select, :include_seconds => true, :labels => { field => false }))
        end)
        expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :count => fields.length-1)
        fields.each do |f|
          expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :text => /#{f}/i) unless field == f
        end
      end

      it "should not render unsafe HTML when :labels[:#{field}] is false" do 
        output_buffer.replace ''
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:created_at, :as => :time_select, :include_seconds => true, :labels => { field => false }))
        end)
        expect(output_buffer).not_to include("&gt;")
      end
      
    end

    it "should not render labels when :labels is falsy" do
      output_buffer.replace ''
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:created_at, :as => :time_select, :include_seconds => true, :labels => false))
      end)
      expect(output_buffer).to have_tag('form li.time_select fieldset ol li label', :count => 0)
    end
  end

  describe ":selected option for setting a value" do
    it "should set the selected value for the form" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:created_at, :as => :datetime_select, :selected => DateTime.new(2018, 10, 4, 12, 00)))
        end
      )

      expect(output_buffer).to have_tag "option[value='12'][selected='selected']"
      expect(output_buffer).to have_tag "option[value='00'][selected='selected']"
    end
  end

  describe ':namespace option' do
    before do
      concat(semantic_form_for(@new_post, :namespace => 'form2') do |builder|
        concat(builder.input(:publish_at, :as => :time_select))
      end)
    end

    it 'should have a tag matching the namespace' do
      expect(output_buffer).to have_tag('#form2_post_publish_at_input')
      expect(output_buffer).to have_tag('#form2_post_publish_at_4i')
      expect(output_buffer).to have_tag('#form2_post_publish_at_5i')
    end
  end
  
  describe "when required" do
    it "should add the required attribute to the input's html options" do
      with_config :use_required_attribute, true do 
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :time_select, :required => true))
        end)
        expect(output_buffer).to have_tag("select[@required]", :count => 2)
      end
    end
  end
  
  describe "when index is provided" do

    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.fields_for(:author, :index => 3) do |author|
          concat(author.input(:created_at, :as => :time_select))
        end)
      end)
    end

    it 'should index the id of the wrapper' do
      expect(output_buffer).to have_tag("li#post_author_attributes_3_created_at_input")
    end

    it 'should index the id of the select tag' do
      expect(output_buffer).to have_tag("input#post_author_attributes_3_created_at_1i")
      expect(output_buffer).to have_tag("input#post_author_attributes_3_created_at_2i")
      expect(output_buffer).to have_tag("input#post_author_attributes_3_created_at_3i")
      expect(output_buffer).to have_tag("select#post_author_attributes_3_created_at_4i")
      expect(output_buffer).to have_tag("select#post_author_attributes_3_created_at_5i")
    end

    it 'should index the name of the select tag' do
      expect(output_buffer).to have_tag("input[@name='post[author_attributes][3][created_at(1i)]']")
      expect(output_buffer).to have_tag("input[@name='post[author_attributes][3][created_at(2i)]']")
      expect(output_buffer).to have_tag("input[@name='post[author_attributes][3][created_at(3i)]']")
      expect(output_buffer).to have_tag("select[@name='post[author_attributes][3][created_at(4i)]']")
      expect(output_buffer).to have_tag("select[@name='post[author_attributes][3][created_at(5i)]']")
    end

  end
  
end



