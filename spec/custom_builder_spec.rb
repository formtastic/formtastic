# coding: utf-8
require File.dirname(__FILE__) + '/test_helper'

describe 'Custom form builders' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end

  describe "@@builder" do
    before do
      @new_post.stub!(:title)
      @new_post.stub!(:body)
      @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
    end
    
    after do
      Formtastic::SemanticFormHelper.builder = Formtastic::SemanticFormBuilder
    end

    it "can be overridden" do

      class CustomFormBuilder < Formtastic::SemanticFormBuilder
        def custom(arg1, arg2, options = {})
          [arg1, arg2, options]
        end
      end

      Formtastic::SemanticFormHelper.builder = CustomFormBuilder

      semantic_form_for(@new_post) do |builder|
        builder.class.should == CustomFormBuilder
        builder.custom("one", "two").should == ["one", "two", {}]
      end
    end

  end

end