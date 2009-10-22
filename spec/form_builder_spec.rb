# coding: utf-8
require File.dirname(__FILE__) + '/test_helper'

describe 'SemanticFormBuilder' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'Formtastic::SemanticFormBuilder#semantic_fields_for' do
    before do
      @new_post.stub!(:author).and_return(::Author.new)
    end

    it 'yields an instance of SemanticFormHelper.builder' do  
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(:author) do |nested_builder|
          nested_builder.class.should == Formtastic::SemanticFormHelper.builder
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
      output_buffer.should_not have_tag('form fieldset.inputs #post[author]_1_login_input')
    end
  end

  describe '#label' do
    it 'should humanize the given attribute' do
      semantic_form_for(@new_post) do |builder|
        builder.label(:login).should have_tag('label', :with => /Login/)
      end
    end

    it 'should be printed as span' do
      semantic_form_for(@new_post) do |builder|
        builder.label(:login, nil, { :required => true, :as_span => true }).should have_tag('span.label abbr')
      end
    end

    describe 'when required is given' do
      it 'should append a required note' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, nil, :required => true).should have_tag('label abbr')
        end
      end

      it 'should allow require option to be given as second argument' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, :required => true).should have_tag('label abbr')
        end
      end
    end

    describe 'when label is given' do
      it 'should allow the text to be given as label option' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, :required => true, :label => 'My label').should have_tag('label', :with => /My label/)
        end
      end

      it 'should return nil if label is false' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, :label => false).should be_blank
        end
      end
    end
  end

end

