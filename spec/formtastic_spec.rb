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

  describe 'form helper wrapper' do
    
    setup do 
      # Resource-oriented styles like form_for(@post) will expect a path method for the object,
      # so we're defining some here.
      def post_path(o); "/posts/1"; end
      def posts_path; "/posts"; end
      def new_post_path; "/posts/new"; end
      
      # Sometimes we need a Post class
      class Post; end
      
      # Sometimes we need a mock @post object 
      @new_post = mock('post')
      @new_post.stub!(:class).and_return(Post)
      @new_post.stub!(:id).and_return(nil)
      @new_post.stub!(:new_record?).and_return(true)
      
      # ERB stuff expects an _erbout variable, so you don't have to set it up at the start of every
      # spec any more.        
      def _erbout; ''; end
      
      # Matching and testing against _erbout is ugly, so let's call it what it is, html.
      def html; _erbout; end
    end
    
    describe '#semantic_form_for' do  
        
      it 'yields an instance of SemanticFormBuilder' do
        semantic_form_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
      
      it 'adds a class of "formtastic" to generated form' do
        semantic_form_for(:post, Post.new, :url => '/hello') do |builder|
        end
        html.should match_xpath("form/@class", /\bformtastic\b/)
      end
      
      it 'can be called with a resource-oriented style' do
        semantic_form_for(@new_post) do |builder|
          builder.object.class.should == Post
          builder.object_name.should == "post"
        end
      end
      
      xit 'can be called with a resource-oriented style with an inline object' do
        semantic_form_for(Post.new) do |builder|
          builder.object.class.should == Post
          builder.object_name.should == "post"
        end
      end
        
      it 'can be called with a generic style and instance variable' do
        semantic_form_for(:post, @new_post, :url => new_post_path) do |builder|
          builder.object.class.should == Post
          builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
        end
      end
      
      it 'can be called with a generic style and inline object' do
        semantic_form_for(:post, Post.new, :url => new_post_path) do |builder|
          builder.object.class.should == Post
          builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
        end
      end
    
      xit 'cannot be called without an object' do
        lambda { 
          semantic_form_for(:post, :url => new_post_path) do |builder| 
          end 
        }.should raise_error
      end
    
    end
    
    describe '#semantic_fields_for' do
      it 'yields an instance of SemanticFormBuilder' do
        semantic_fields_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
    end
    
    describe '#semantic_form_remote_for' do
      it 'yields an instance of SemanticFormBuilder' do
        semantic_form_remote_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
    end
    
    describe '#semantic_form_for_remote' do
      it 'yields an instance of SemanticFormBuilder' do
        semantic_form_remote_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
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
