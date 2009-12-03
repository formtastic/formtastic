# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe 'SemanticFormBuilder#semantic_fields_for' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    @new_post.stub!(:author).and_return(::Author.new)
  end

  it 'yields an instance of SemanticFormHelper.builder' do  
    semantic_form_for(@new_post) do |builder|
      builder.semantic_fields_for(:author) do |nested_builder|
        nested_builder.class.should == ::Formtastic::SemanticFormHelper.builder
      end
    end
  end
  
  it 'nests the object name' do
    semantic_form_for(@new_post) do |builder|
      builder.semantic_fields_for(@bob) do |nested_builder|
        nested_builder.object_name.should == 'post[author]'
      end
    end
  end
  
  it 'should sanitize html id for li tag' do
    @bob.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
    semantic_form_for(@new_post) do |builder|
      builder.semantic_fields_for(@bob, :index => 1) do |nested_builder|
        concat(nested_builder.inputs(:login))
      end
    end
    output_buffer.should have_tag('form fieldset.inputs #post_author_1_login_input')
    # Not valid selector, so using good ol' regex
    output_buffer.should_not =~ /id="post\[author\]_1_login_input"/
    # <=> output_buffer.should_not have_tag('form fieldset.inputs #post[author]_1_login_input')
  end

end

