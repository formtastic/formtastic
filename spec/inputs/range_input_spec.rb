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
  
    before { mock_everything }
  
    it "uses min and max from greater_than_or_equal_to and less_than_or_equal_to validation options" do
      @james.class.stub!(:validators_on).with(:age).and_return([
        active_model_numericality_validator([:age], {:only_integer=>false, :allow_nil=>false, :greater_than_or_equal_to=>1930, :less_than_or_equal_to=>(Time.now.year-5)})
      ])
      
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range))
      end)
      
      output_buffer.should have_tag("form li input[step=\"1\"][min=\"1930\"][max=\"#{Time.now.year - 5}\"]")
    end
    
    it "adjusts greater_than and less_than validation options by 1" do        
      @james.class.stub!(:validators_on).with(:age).and_return([
        active_model_numericality_validator([:age], {:only_integer=>false, :allow_nil=>false, :greater_than=>0, :less_than=>6})
      ])
      
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range))
      end)
      
      output_buffer.should have_tag("form li input[step=\"1\"][min=\"1\"][max=\"5\"]")
    end
    
    it "defaults the step to 1" do        
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range))
      end)
      output_buffer.should have_tag("form li input[step=\"1\"]")
    end
    
    it "defaults the min to 1" do        
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range))
      end)
      output_buffer.should have_tag("form li input[min=\"1\"]")
    end
    
    it "defaults the max to 100" do        
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range))
      end)
      output_buffer.should have_tag("form li input[max=\"100\"]")
    end
    
    it "will look for the non-standard :step validation option" do        
      @james.class.stub!(:validators_on).with(:age).and_return([
        active_model_numericality_validator([:age], {:only_integer=>false, :allow_nil=>false, :greater_than=>0, :less_than=>6, :step => 0.5})
      ])
      
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range))
      end)
      
      output_buffer.should have_tag("form li input[step=\"0.5\"][min=\"1\"][max=\"5\"]")
    end
    
    it "allows options hash to override validations" do
      @james.class.stub!(:validators_on).with(:age).and_return([
        active_model_numericality_validator([:age], {:only_integer=>false, :allow_nil=>false, :greater_than=>5, :less_than=>50, :step => 0.5})
      ])
      
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range, :in => 52..108, :step => 2))
      end)
      
      output_buffer.should have_tag("form li input[step=\"2\"][min=\"52\"][max=\"108\"]")
    end
    
    it "should allow input_html hash to override validations and options" do
      @james.class.stub!(:validators_on).with(:age).and_return([
        active_model_numericality_validator([:age], {:only_integer=>false, :allow_nil=>false, :greater_than=>5, :less_than=>50, :step => 0.5})
      ])
      
      concat(semantic_form_for(@james) do |builder|
        concat(builder.input(:age, :as => :range, :in => 52..108, :step => 2, :input_html => { :in => 53..109, :step => 3 }))
      end)
      
      output_buffer.should have_tag("form li input[step=\"3\"][min=\"53\"][max=\"109\"]")
    end
    
  end 

end

