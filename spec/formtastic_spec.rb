require File.dirname(__FILE__) + '/test_helper'
require 'justin_french/formtastic' 

describe 'Formtastic' do
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionController::PolymorphicRoutes
  
  include JustinFrench::Formtastic::SemanticFormHelper

  def protect_against_forgery?
    false
  end

  describe '#semantic_form_for' do
    it 'yields an instance of SemanticFormBuilder' do
      _erbout = ''
      semantic_form_for(:post, Object.new, :url => '/hello') do |builder|
        builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
      end
    end

    it 'adds a class of "formtastic" to generated form' do
      _erbout = ''
      semantic_form_for(:post, Object.new, :url => '/hello') do |builder|
      end
      _erbout.should match_xpath("form/@class", /\bformtastic\b/)
    end
  end

  describe '#input' do
    it 'generates a text field with label' do
      @post = mock('post')
      @post.stub!(:title).and_return('hello')
      @post.stub!(:errors).and_return(mock('errors', :on => nil))
      @post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
      _erbout = ''
      semantic_form_for(:post, @post, :url => '/hello') do |builder|
        _erbout += builder.input :title
      end
      _erbout.should have_xpath("form/li/label")
      _erbout.should have_xpath("form/li/input")
      _erbout.should match_xpath("form/li/input/@value", "hello")
    end

    it 'generates a text area with label' do
      @post = mock('post')
      @post.stub!(:body).and_return('hello')
      @post.stub!(:errors).and_return(mock('errors', :on => nil))
      @post.stub!(:column_for_attribute).and_return(mock('column', :type => :text))
      _erbout = ''
      semantic_form_for(:post, @post, :url => '/hello') do |builder|
        _erbout += builder.input :body
      end
      _erbout.should have_xpath("form/li/label")
      _erbout.should have_xpath("form/li/textarea")
      _erbout.should match_xpath("form/li/textarea", "hello")
    end
  end
end
