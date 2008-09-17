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
  end
  
  describe 'form helper wrapper' do
  
    describe '#semantic_form_for' do  
        
      it 'yields an instance of SemanticFormBuilder' do
        _erbout = ''
        semantic_form_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
      
      it 'adds a class of "formtastic" to generated form' do
        _erbout = ''
        semantic_form_for(:post, Post.new, :url => '/hello') do |builder|
        end
        _erbout.should have_tag("form.formtastic")
      end
      
      it 'can be called with a resource-oriented style' do
        _erbout = ''
        semantic_form_for(@new_post) do |builder|
          builder.object.class.should == Post
          builder.object_name.should == "post"
        end
      end
      
      xit 'can be called with a resource-oriented style with an inline object' do
        _erbout = ''
        semantic_form_for(Post.new) do |builder|
          builder.object.class.should == Post
          builder.object_name.should == "post"
        end
      end
        
      it 'can be called with a generic style and instance variable' do
        _erbout = ''
        semantic_form_for(:post, @new_post, :url => new_post_path) do |builder|
          builder.object.class.should == Post
          builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
        end
      end
      
      it 'can be called with a generic style and inline object' do
        _erbout = ''
        semantic_form_for(:post, Post.new, :url => new_post_path) do |builder|
          builder.object.class.should == Post
          builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
        end
      end
    
      xit 'cannot be called without an object' do
        _erbout = ''
        lambda { 
          semantic_form_for(:post, :url => new_post_path) do |builder| 
          end 
        }.should raise_error
      end
    
    end
    
    describe '#semantic_fields_for' do
      it 'yields an instance of SemanticFormBuilder' do
        _erbout = ''
        semantic_fields_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
    end
    
    describe '#semantic_form_remote_for' do
      it 'yields an instance of SemanticFormBuilder' do
        _erbout = ''
        semantic_form_remote_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
    end
    
    describe '#semantic_form_for_remote' do
      it 'yields an instance of SemanticFormBuilder' do
        _erbout = ''
        semantic_form_remote_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
    end
    
  end

  describe '#input' do
    
    setup do 
      @new_post.stub!(:title)
      @new_post.stub!(:body)
      @new_post.stub!(:errors).and_return(mock('errors', :on => nil))
      @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
    end
    
    it 'should raise an error when the object does not respond to the method' do
      _erbout = ''
      semantic_form_for(@new_post) do |builder| 
        lambda { builder.input :method_on_post_that_doesnt_exist }.should raise_error("@post doesn't respond to the method method_on_post_that_doesnt_exist")
      end 
    end
    
    it 'should create a list item for each input' do
      _erbout = ''
      semantic_form_for(@new_post) do |builder| 
        _erbout += builder.input(:title)
        _erbout += builder.input(:body)
      end
       _erbout.should have_tag('form li', :count => 2)
    end
    
    describe ':required option' do
    
      it 'should set a "required" class when true' do
        _erbout = ''
        semantic_form_for(@new_post) do |builder| 
          _erbout += builder.input(:title, :required => true)
        end
        _erbout.should_not have_tag('form li.optional')
        _erbout.should have_tag('form li.required')
      end
      
      it 'should set an "optional" class when false' do
        _erbout = ''
        semantic_form_for(@new_post) do |builder| 
          _erbout += builder.input(:title, :required => false)
        end
        _erbout.should_not have_tag('form li.required')
        _erbout.should have_tag('form li.optional')
      end
      
      it 'should use the default value when none is provided' do
        JustinFrench::Formtastic::SemanticFormBuilder.all_fields_required_by_default.should == true
        JustinFrench::Formtastic::SemanticFormBuilder.all_fields_required_by_default = false
        _erbout = ''
        semantic_form_for(@new_post) do |builder| 
          _erbout += builder.input(:title)
        end
        _erbout.should_not have_tag('form li.required')
        _erbout.should have_tag('form li.optional')
      end
      
      it 'should append the "required" string to the label when required' do
        string = JustinFrench::Formtastic::SemanticFormBuilder.required_string = " required yo!" # ensure there's something in the string 
        _erbout = ''
        semantic_form_for(@new_post) do |builder| 
          _erbout += builder.input(:title, :required => true)
        end
        _erbout.should have_tag('form li.required label', /#{string}$/)
      end
      
      it 'should append the "optional" string to the label when optional' do 
        string = JustinFrench::Formtastic::SemanticFormBuilder.optional_string = " optional yo!" # ensure there's something in the string 
        _erbout = ''
        semantic_form_for(@new_post) do |builder| 
          _erbout += builder.input(:title, :required => false)
        end
        _erbout.should have_tag('form li.optional label', /#{string}$/)
      end
      
    end
    
    describe ':as option' do
      
      describe 'when not specified' do
        
        it 'should raise an error for methods that don\'t have a db column' do
          _erbout = ''
          @new_post.stub!(:method_without_a_database_column)
          @new_post.stub!(:column_for_attribute).and_return(nil)
          semantic_form_for(@new_post) do |builder| 
            lambda { 
              builder.send(:default_input_type, @new_post, :method_without_a_database_column) 
            }.should raise_error("Cannot guess an input type for 'method_without_a_database_column' - please set :as option")
          end
        end
          
        it 'should default to a :select for column names ending in "_id"' do
          _erbout = ''
          @new_post.stub!(:user_id)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :integer))
          semantic_form_for(@new_post) do |builder| 
            builder.send(:default_input_type, @new_post, :user_id).should == :select
          end
        end
                
        it 'should default to a :password for :string column types with "password" in the method name' do
          _erbout = ''
          @new_post.stub!(:password)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string))
          semantic_form_for(@new_post) do |builder| 
            builder.send(:default_input_type, @new_post, :password).should == :password
          end
        end
                
        it 'should default to a :text for :text column types' do
          _erbout = ''
          @new_post.stub!(:body)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :text))
          semantic_form_for(@new_post) do |builder| 
            builder.send(:default_input_type, @new_post, :body).should == :text
          end
        end
        
        it 'should default to a :date for :date column types' do
          _erbout = ''
          @new_post.stub!(:publish_on)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :date))
          semantic_form_for(@new_post) do |builder| 
            builder.send(:default_input_type, @new_post, :publish_on).should == :date
          end
        end
        
        it 'should default to a :datetime for :datetime and :timestamp column types' do
          _erbout = ''
          @new_post.stub!(:publish_at)
          [:datetime, :timestamp].each do |column_type|
            @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => column_type))
            semantic_form_for(@new_post) do |builder| 
              builder.send(:default_input_type, @new_post, :publish_at).should == :datetime
            end
          end
        end
        
        it 'should default to a :time for :time column types' do
          _erbout = ''
          @new_post.stub!(:publish_at)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :time))
          semantic_form_for(@new_post) do |builder| 
            builder.send(:default_input_type, @new_post, :publish_at).should == :time
          end
        end
        
        it 'should default to a :boolean for :boolean column types' do
          _erbout = ''
          @new_post.stub!(:public)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
          semantic_form_for(@new_post) do |builder| 
            builder.send(:default_input_type, @new_post, :public).should == :boolean
          end
        end
        
        it 'should default to a :string for :string column types' do
          _erbout = ''
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string))
          semantic_form_for(@new_post) do |builder| 
            builder.send(:default_input_type, @new_post, :title).should == :string
          end
        end
        
        it 'should default to a :numeric for :integer, :float and :decimal column types' do
          _erbout = ''
          @new_post.stub!(:comment_count)
          [:integer, :float, :decimal].each do |column_type|
            @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => column_type))
            semantic_form_for(@new_post) do |builder| 
              builder.send(:default_input_type, @new_post, :comment_count).should == :numeric
            end
          end
        end
      
      end
      
    end
    
    describe ':label option' do
    end
    
    describe ':hint option' do
    end
    
    # these original specs will eventually go away, once the coverage is up in the new stuff
    it 'generates a text field with label' do
      _erbout = ''
      semantic_form_for(@new_post) do |builder|
        _erbout += builder.input :title
      end
      _erbout.should have_tag("form li label")
      _erbout.should have_tag("form li input")
    end
    
    it 'generates a textarea with label' do
      _erbout = ''
      @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :text, :limit => nil))
      
      semantic_form_for(@new_post) do |builder|
        _erbout += builder.input :body
      end
      _erbout.should have_tag("form li label")
      _erbout.should have_tag("form li textarea")
    end
    
  end
end
