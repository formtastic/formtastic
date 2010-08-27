# coding: utf-8
require 'spec_helper'

describe 'string input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end
  
  describe "when object is provided" do
    before do
      @form = semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :string))
      end
    end
    
    it_should_have_input_wrapper_with_class(:string)
    it_should_have_input_wrapper_with_id("post_title_input")
    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("post_title")
    it_should_have_input_with_id("post_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("post[title]")
    it_should_have_maxlength_matching_column_limit
    it_should_use_default_text_field_size_for_columns_longer_than_default_text_field_size(:string)
    it_should_use_column_size_for_columns_shorter_than_default_text_field_size(:string)
    it_should_use_default_text_field_size_when_method_has_no_database_column(:string)
    it_should_apply_custom_input_attributes_when_input_html_provided(:string)
    it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
    it_should_apply_error_logic_for_input_type(:string)

    describe 'and the validation reflection plugin is available' do
      def input_field_for_method_should_have_maxlength(method, maxlength)
        form = semantic_form_for(@new_post) do |builder|
          concat(builder.input(method))
        end
        output_buffer.concat(form) if Formtastic::Util.rails3?
        output_buffer.should have_tag("form li input[@maxlength='#{maxlength}']")
      end

      describe 'and validates_length_of was called for the method' do
        it 'should have a maxlength matching validation range top' do
          @new_post.class.should_receive(:reflect_on_validations_for).with(:title).at_least(2).and_return([
            mock('MacroReflection', :macro => :validates_length_of, :name => :title, :options => {:within => 5..42})
          ])

          input_field_for_method_should_have_maxlength :title, 42
        end

        it 'should have a maxlength matching validation maximum' do
          @new_post.class.should_receive(:reflect_on_validations_for).with(:title).at_least(2).and_return([
            mock('MacroReflection', :macro => :validates_length_of, :name => :title, :options => {:maximum => 42})
          ])
          input_field_for_method_should_have_maxlength :title, 42
        end
      end

      describe 'and validates_length_of was not called for the method' do
        it "should use default maxlength" do
          @new_post.class.should_receive(:reflect_on_validations_for).with(:title).at_least(2).and_return([])
          input_field_for_method_should_have_maxlength :title, 50
        end
      end
    end
  end
  
  describe "when no object is provided" do
    before do
      @form = semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:title, :as => :string))
      end
    end
    
    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("project_title")
    it_should_have_input_with_id("project_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("project[title]")
  end
  
  describe "when size is nil" do
    before do
      @form = semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:title, :as => :string, :input_html => {:size => nil}))
      end
    end
  
    it "should have no size attribute" do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should_not have_tag("input[@size]")
    end
  end
  
end

