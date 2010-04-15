# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe 'SemanticFormBuilder#errors_on' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    @title_errors = ['must not be blank', 'must be longer than 10 characters', 'must be awesome']
    @errors = mock('errors')
    @new_post.stub!(:errors).and_return(@errors)
  end
  
  describe 'when there are errors' do
    before do
      @errors.stub!(:[]).with(:title).and_return(@title_errors)
    end
    
    it 'should render a paragraph with the errors joined into a sentence when inline_errors config is :sentence' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :sentence
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('p.inline-errors', @title_errors.to_sentence)
      end
    end
    
    it 'should render an unordered list with the class errors when inline_errors config is :list' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :list
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('ul.errors')
        @title_errors.each do |error|
          builder.errors_on(:title).should have_tag('ul.errors li', error)
        end
      end
    end

    it 'should render a paragraph with the first error when inline_errors config is :first' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :first
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('p.inline-errors', @title_errors.first)
      end
    end
    
    it 'should return nil when inline_errors config is :none' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :none
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should be_nil
      end
    end
    
  end
  
  describe 'when there are no errors (nil)' do
    before do
      @errors.stub!(:[]).with(:title).and_return(nil)
    end
    
    it 'should return nil when inline_errors config is :sentence, :list or :none' do
      [:sentence, :list, :none].each do |config|
        ::Formtastic::SemanticFormBuilder.inline_errors = config
        semantic_form_for(@new_post) do |builder|
          builder.errors_on(:title).should be_nil
        end
      end
    end
  end
  
  describe 'when there are no errors (empty array)' do
    before do
      @errors.stub!(:[]).with(:title).and_return([])
    end
    
    it 'should return nil when inline_errors config is :sentence, :list or :none' do
      [:sentence, :list, :none].each do |config|
        ::Formtastic::SemanticFormBuilder.inline_errors = config
        semantic_form_for(@new_post) do |builder|
          builder.errors_on(:title).should be_nil
        end
      end
    end
  end
  
end

