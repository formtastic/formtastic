# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

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

    it 'should html escape the label string' do
      semantic_form_for(@new_post) do |builder|
        builder.label(:login, :required => false, :label => '<b>My label</b>').should == "<label for=\"post_login\">&lt;b&gt;My label&lt;/b&gt;</label>"
      end
    end
  end
  
end

