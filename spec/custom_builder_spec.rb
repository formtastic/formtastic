# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe 'Formtastic::SemanticFormHelper.builder' do

  include FormtasticSpecHelper
  
  class MyCustomFormBuilder < ::Formtastic::SemanticFormBuilder
    def awesome_input(method, options)
      self.text_field(method)
    end
  end
  
  before do
    @output_buffer = ''
    mock_everything
  end
  
  it 'is the Formtastic::SemanticFormBuilder by default' do
    ::Formtastic::SemanticFormHelper.builder.should == ::Formtastic::SemanticFormBuilder
  end
  
  it 'can be configured to use your own custom form builder' do
    # Set it to a custom builder class
    ::Formtastic::SemanticFormHelper.builder = MyCustomFormBuilder
    ::Formtastic::SemanticFormHelper.builder.should == MyCustomFormBuilder
    
    # Reset it to the default
    ::Formtastic::SemanticFormHelper.builder = ::Formtastic::SemanticFormBuilder
    ::Formtastic::SemanticFormHelper.builder.should == ::Formtastic::SemanticFormBuilder
  end
  
  describe "when using a custom builder" do
    
    before do
      @new_post.stub!(:title)
      ::Formtastic::SemanticFormHelper.builder = MyCustomFormBuilder
    end
    
    after do
      ::Formtastic::SemanticFormHelper.builder = ::Formtastic::SemanticFormBuilder
    end
    
    describe "semantic_form_for" do
      
      it "should yeild and instance of the custom builder" do
        semantic_form_for(@new_post) do |builder|
          builder.class.should == MyCustomFormBuilder
        end
      end
      
      it "should allow me to call my custom input" do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :awesome))
        end
      end
    
    end
    
  end

end