# coding: utf-8
require File.dirname(__FILE__) + '/test_helper'

describe 'SemanticFormBuilder#label' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end

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

