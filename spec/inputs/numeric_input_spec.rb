# encoding: utf-8
require 'spec_helper'

describe 'numeric input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:title, :as => :numeric))
    end)
  end

  it_should_have_input_wrapper_with_class(:numeric)
  it_should_have_input_wrapper_with_id("post_title_input")
  it_should_have_label_with_text(/Title/)
  it_should_have_label_for("post_title")
  it_should_have_input_with_id("post_title")
  it_should_have_input_with_type(:number)
  it_should_have_input_with_name("post[title]")
  it_should_use_default_text_field_size_when_not_nil(:string)
  it_should_not_use_default_text_field_size_when_nil(:string)
  it_should_apply_custom_input_attributes_when_input_html_provided(:string)
  it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
  it_should_apply_error_logic_for_input_type(:numeric)

  describe "when no object is provided" do
    before do
      concat(semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:title, :as => :numeric))
      end)
    end

    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("project_title")
    it_should_have_input_with_id("project_title")
    it_should_have_input_with_type(:number)
    it_should_have_input_with_name("project[title]")
  end

  describe "when namespace provided" do
    before do
      concat(semantic_form_for(@new_post, :namespace => :context2) do |builder|
        concat(builder.input(:title, :as => :numeric))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_post_title_input")
    it_should_have_label_and_input_with_id("context2_post_title")
  end
  
  describe "when required" do
    it "should add the required attribute to the input's html options" do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :numeric, :required => true))
      end)
      output_buffer.should have_tag("input[@required]")
    end
  end
  
  describe "when validations require a minimum value (:greater_than)" do
    before do
      @new_post.class.stub!(:validators_on).with(:title).and_return([
        active_model_numericality_validator([:title], {:only_integer=>false, :allow_nil=>false, :greater_than=>2})
      ])
    end
    
    it "should add a max attribute to the input one greater than the validation" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric)
      end)
      output_buffer.should have_tag('input[@min="3"]')
    end
    
    it "should allow :input_html to override :min" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric, :input_html => { :min => 102 })
      end)
      output_buffer.should have_tag('input[@min="102"]')
    end
  end
  
  describe "when validations require a minimum value (:greater_than_or_equal_to)" do
    before do
      @new_post.class.stub!(:validators_on).with(:title).and_return([
        active_model_numericality_validator([:title], {:only_integer=>false, :allow_nil=>false, :greater_than_or_equal_to=>2})
      ])
    end
    
    it "should add a max attribute to the input equal to the validation" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric)
      end)
      output_buffer.should have_tag('input[@min="2"]')
    end
  end
  
  describe "when validations require a maximum value (:less_than)" do
    before do
      @new_post.class.stub!(:validators_on).with(:title).and_return([
        active_model_numericality_validator([:title], {:only_integer=>false, :allow_nil=>false, :less_than=>20})
      ])
    end
    
    it "should add a min attribute to the input one less than the validation" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric)
      end)
      output_buffer.should have_tag('input[@max="19"]')
    end
    
    it "should allow :input_html to override :min" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric, :input_html => { :max => 48 })
      end)
      output_buffer.should have_tag('input[@max="48"]')
    end
  end  

  describe "when validations require a maximum value (:less_than_or_equal_to)" do
    before do
      @new_post.class.stub!(:validators_on).with(:title).and_return([
        active_model_numericality_validator([:title], {:only_integer=>false, :allow_nil=>false, :less_than_or_equal_to=>20})
      ])
    end
    
    it "should add a min attribute to the input one less than the validation" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric)
      end)
      output_buffer.should have_tag('input[@max="20"]')
    end
  end
  
  describe "when validations require conflicting minimum values (:greater_than, :greater_than_or_equal_to)" do
    before do
      @new_post.class.stub!(:validators_on).with(:title).and_return([
        active_model_numericality_validator([:title], {:only_integer=>false, :allow_nil=>false, :greater_than => 20, :greater_than_or_equal_to=>2})
      ])
    end
    
    it "should add a max attribute to the input equal to the :greater_than_or_equal_to validation" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric)
      end)
      output_buffer.should have_tag('input[@min="2"]')
    end
  end
  
  describe "when validations require conflicting maximum values (:less_than, :less_than_or_equal_to)" do
    before do
      @new_post.class.stub!(:validators_on).with(:title).and_return([
        active_model_numericality_validator([:title], {:only_integer=>false, :allow_nil=>false, :less_than => 20, :less_than_or_equal_to=>2})
      ])
    end
    
    it "should add a max attribute to the input equal to the :greater_than_or_equal_to validation" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric)
      end)
      output_buffer.should have_tag('input[@max="2"]')
    end
  end
  
  describe "when validations require only an integer (:only_integer)" do
    
    before do
      @new_post.class.stub!(:validators_on).with(:title).and_return([
        active_model_numericality_validator([:title], {:allow_nil=>false, :only_integer=>true})
      ])
    end
    
    it "should add a step=1 attribute to the input to signify that only whole numbers are allowed" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric)
      end)
      output_buffer.should have_tag('input[@step="1"]')
    end
    
    it "should let input_html override :step" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :numeric, :input_html => { :step => 3 })
      end)
      output_buffer.should have_tag('input[@step="3"]')
    end
  end
  
end

