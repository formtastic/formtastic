# encoding: utf-8
require 'spec_helper'
require 'active_record'

describe 'range input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe "when object is provided" do
    before do
      concat(semantic_form_for(@bob) do |builder|
        concat(builder.input(:age, :as => :range))
      end)
    end

    it_should_have_input_wrapper_with_class(:range)
    it_should_have_input_wrapper_with_id("author_age_input")
    it_should_have_label_with_text(/Age/)
    it_should_have_label_for("author_age")
    it_should_have_input_with_id("author_age")
    it_should_have_input_with_type(:range)
    it_should_have_input_with_name("author[age]")

  end

  describe "when namespace is provided" do

    before do
      concat(semantic_form_for(@james, :namespace => "context2") do |builder|
        concat(builder.input(:age, :as => :range))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_author_age_input")
    it_should_have_label_and_input_with_id("context2_author_age")

  end
  
  describe "core processing" do
  
    before { mock_everything; @options = {} }
  
    describe "with validation_reflection" do
      
      before do
        # Insane, but we need to test with and without validation_reflection
        ::Author.stub!(:reflect_on_validations_for).with(:age).and_return([ActiveRecord::Reflection::MacroReflection.new(:validates_numericality_of, :age, {:greater_than => 0, :less_than => 6}, ::Author)])
      end
      
      it "works with alternate validation options" do
        ::Author.stub!(:reflect_on_validations_for).with(:age).and_return([ActiveRecord::Reflection::MacroReflection.new(:validates_numericality_of, :age, {:greater_than_or_equal_to => 1930, :less_than_or_equal_to => (Time.now.year - 5)}, ::Author)])
        
        concat(semantic_form_for(@james) do |builder|
          concat(builder.input(:age, @options.merge(:as => :range)))
        end)
        
        output_buffer.should have_tag("form li input[step=\"1\"][min=\"1930\"][max=\"#{Time.now.year - 5}\"]")
      end
    
      it "assigns range and step from model" do        
        concat(semantic_form_for(@james) do |builder|
          concat(builder.input(:age, @options.merge(:as => :range)))
        end)
        
        output_buffer.should have_tag("form li input[step=\"1\"][min=\"1\"][max=\"5\"]")
      end
      
      it "allows for overriding range and step values" do
        @options.merge! :in => 9..10, :step => 0.2
        
        concat(semantic_form_for(@james) do |builder|
          concat(builder.input(:age, @options.merge(:as => :range)))
        end)
        
        output_buffer.should have_tag("form li input[step=\"0.2\"][min=\"9\"][max=\"10\"]")
      end
    
    end
    
  end 

end

