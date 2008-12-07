require File.dirname(__FILE__) + '/test_helper'
require 'justin_french/formtastic' 

module FormtasticSpecHelper
  
  def should_have_maxlength_matching_column_limit(method_name, as, column_type)
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(method_name, :as => as))
    end
    @new_post.column_for_attribute(method_name).limit.should == 50
    output_buffer.should have_tag("form li input[@maxlength='#{@new_post.column_for_attribute(method_name).limit}']")
  end
  
  def should_use_default_text_size_for_columns_longer_than_default(method_name, as, column_type)
    default_size = JustinFrench::Formtastic::SemanticFormBuilder::DEFAULT_TEXT_FIELD_SIZE
    column_limit_larger_than_default = default_size * 2
    @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => column_type, :limit => column_limit_larger_than_default))
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(method_name, :as => as))
    end
    output_buffer.should have_tag("form li input[@size='#{default_size}']")
  end
  
  def should_use_the_column_size_for_columns_shorter_than_default(method_name, as, column_type)
    default_size = JustinFrench::Formtastic::SemanticFormBuilder::DEFAULT_TEXT_FIELD_SIZE
    column_limit_shorter_than_default = 1
    @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => column_type, :limit => column_limit_shorter_than_default))
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(method_name, :as => as))
    end
    output_buffer.should have_tag("form li input[@size='#{column_limit_shorter_than_default}']")
  end
  
  def should_use_default_size_for_methods_without_columns(as)
    default_size = JustinFrench::Formtastic::SemanticFormBuilder::DEFAULT_TEXT_FIELD_SIZE
    @new_post.stub!(:method_without_column)
    semantic_form_for(@new_post) do |builder|
      concat(builder.input(:method_without_column, :as => as))
    end
    output_buffer.should have_tag("form li input[@size='#{default_size}']")
  end
  
  def default_input_type(column_type, column_name = :generic_column_name)
    @new_post.stub!(column_name)
    @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => column_type))
    semantic_form_for(@new_post) do |builder| 
      @default_type = builder.send(:default_input_type, @new_post, column_name)
    end
    return @default_type
  end
  
end

describe 'Formtastic' do
    
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::CaptureHelper
  include ActiveSupport
  include ActionController::PolymorphicRoutes
  
  include JustinFrench::Formtastic::SemanticFormHelper
  
  attr_accessor :output_buffer

  def protect_against_forgery?; false; end
  
  before do 
    @output_buffer = ''
    
    # Resource-oriented styles like form_for(@post) will expect a path method for the object,
    # so we're defining some here.
    def post_path(o); "/posts/1"; end
    def posts_path; "/posts"; end
    def new_post_path; "/posts/new"; end
    
    # Sometimes we need some classes
    class Post; 
      def id; end
    end
    class Author; end
    
    # Sometimes we need a mock @post object 
    @new_post = mock('post')
    @new_post.stub!(:class).and_return(Post)
    @new_post.stub!(:id).and_return(nil)
    @new_post.stub!(:new_record?).and_return(true)
    @new_post.stub!(:errors).and_return(mock('errors', :on => nil))
    
  end
  
  describe 'SemanticFormHelper' do
  
    describe '#semantic_form_for' do  
             
      it 'yields an instance of SemanticFormBuilder' do
        semantic_form_for(:post, Post.new, :url => '/hello') do |builder|
          builder.class.should == JustinFrench::Formtastic::SemanticFormBuilder  
        end
      end
      
      it 'adds a class of "formtastic" to generated form' do
        semantic_form_for(:post, Post.new, :url => '/hello') do |builder|
        end
        output_buffer.should have_tag("form.formtastic")
      end
      
      it 'can be called with a resource-oriented style' do
        semantic_form_for(@new_post) do |builder|
          builder.object.class.should == Post
          builder.object_name.should == "post"
        end
      end
      
      it 'can be called with a resource-oriented style with an inline object' do
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

  describe 'SemanticFormBuilder' do
    
    include FormtasticSpecHelper
    
    describe '#input' do
      
      before do 
        @new_post.stub!(:title)
        @new_post.stub!(:body)
        @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
      end
      
      describe 'arguments and options' do
        
        it 'should require the first argument (the method on form\'s object)' do
            lambda { 
            semantic_form_for(@new_post) do |builder| 
              concat(builder.input()) # no args passed in at all
            end
          }.should raise_error(ArgumentError)
        end
        
        it 'should raise an error when the object does not respond to the method supplied in the first argument' do
            semantic_form_for(@new_post) do |builder| 
            lambda { builder.input(:method_on_post_that_doesnt_exist) }.should raise_error(NoMethodError)
          end 
        end
        
        describe ':required option' do

          describe 'when true' do

            before do
              @new_post.class.should_not_receive(:reflect_on_all_validations)
            end

            it 'should set a "required" class' do
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:title, :required => true))
              end
              output_buffer.should_not have_tag('form li.optional')
              output_buffer.should have_tag('form li.required')
            end

            it 'should append the "required" string to the label' do
              string = JustinFrench::Formtastic::SemanticFormBuilder.required_string = " required yo!" # ensure there's something in the string 
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:title, :required => true))
              end
              output_buffer.should have_tag('form li.required label', /#{string}$/)
            end

          end

          describe 'when false' do

            before do
              @new_post.class.should_not_receive(:reflect_on_all_validations)
            end

            it 'should set an "optional" class' do
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:title, :required => false))
              end
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')
            end

            it 'should append the "optional" string to the label' do 
              string = JustinFrench::Formtastic::SemanticFormBuilder.optional_string = " optional yo!" # ensure there's something in the string 
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:title, :required => false))
              end
              output_buffer.should have_tag('form li.optional label', /#{string}$/)
            end

          end

          describe 'when not provided' do

            describe 'and the validation reflection plugin is available' do

              before do
                @new_post.class.stub!(:method_defined?).with(:reflect_on_all_validations).and_return(true)
              end

              describe 'and validates_presence_of was called for the method' do

                before do
                  @new_post.class.should_receive(:reflect_on_all_validations).and_return([
                    mock('MacroReflection', :macro => :validates_presence_of, :name => :title)
                  ])
                end

                it 'should be required' do
                  semantic_form_for(@new_post) do |builder| 
                    concat(builder.input(:title))
                  end
                  output_buffer.should have_tag('form li.required')
                  output_buffer.should_not have_tag('form li.optional')
                end

              end

              describe 'and validates_presence_of was not called for the method' do

                before do
                  @new_post.class.should_receive(:reflect_on_all_validations).and_return([])
                end

                it 'should not be required' do
                  semantic_form_for(@new_post) do |builder| 
                    concat(builder.input(:title))
                  end
                  output_buffer.should_not have_tag('form li.required')
                  output_buffer.should have_tag('form li.optional')
                end

              end

            end

            describe 'and the validation reflection plugin is not available' do

              it 'should use the default value' do
                JustinFrench::Formtastic::SemanticFormBuilder.all_fields_required_by_default.should == true
                JustinFrench::Formtastic::SemanticFormBuilder.all_fields_required_by_default = false
                semantic_form_for(@new_post) do |builder| 
                  concat(builder.input(:title))
                end
                output_buffer.should_not have_tag('form li.required')
                output_buffer.should have_tag('form li.optional')
              end

            end

          end        

        end

        describe ':as option' do

          describe 'when not provided' do

            it 'should raise an error (and ask for the :as option to be specified) for methods that don\'t have a column in the database' do
              @new_post.stub!(:method_without_a_database_column)
              @new_post.stub!(:column_for_attribute).and_return(nil)
              semantic_form_for(@new_post) do |builder| 
                lambda { 
                  builder.send(:default_input_type, @new_post, :method_without_a_database_column) 
                }.should raise_error("Cannot guess an input type for 'method_without_a_database_column' - please set :as option")
              end
            end

            it 'should default to :select for column names ending in "_id"' do
              default_input_type(:integer, :user_id).should == :select
              default_input_type(:integer, :section_id).should == :select
            end

            it 'should default to :password for :string column types with "password" in the method name' do
              default_input_type(:string, :password).should == :password
              default_input_type(:string, :hashed_password).should == :password
              default_input_type(:string, :password_hash).should == :password
            end

            it 'should default to :text for :text column types' do
              default_input_type(:text).should == :text
            end

            it 'should default to :date for :date column types' do
              default_input_type(:date).should == :date
            end

            it 'should default to :datetime for :datetime and :timestamp column types' do
              default_input_type(:datetime).should == :datetime
              default_input_type(:timestamp).should == :datetime
            end

            it 'should default to :time for :time column types' do
              default_input_type(:time).should == :time
            end

            it 'should default to :boolean for :boolean column types' do
              default_input_type(:boolean).should == :boolean
            end

            it 'should default to :string for :string column types' do
              default_input_type(:string).should == :string
            end

            it 'should default to :numeric for :integer, :float and :decimal column types' do
              default_input_type(:integer).should == :numeric
              default_input_type(:float).should == :numeric
              default_input_type(:decimal).should == :numeric
            end

          end

          it 'should call the corresponding input method' do
            [:select, :radio, :password, :text, :date, :datetime, :time, :boolean, :boolean_select, :string, :numeric].each do |input_style|
              @new_post.stub!(:generic_column_name)
              @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
              semantic_form_for(@new_post) do |builder| 
                builder.should_receive(:"#{input_style}_input").once.and_return("fake HTML output from #input")
                concat(builder.input(:generic_column_name, :as => input_style))
              end
            end
          end

        end

        describe ':label option' do

          describe 'when provided' do

            it 'should be passed down to the label tag' do
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:title, :label => "Kustom"))
              end
              output_buffer.should have_tag("form li label", /Kustom/)
            end

          end

          describe 'when not provided' do

            it 'should default the method name, passing it down to the label tag' do
              @new_post.stub!(:meta_description) # a two word method name
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:meta_description))
              end
              output_buffer.should have_tag("form li label", /#{'meta_description'.humanize}/)
              output_buffer.should have_tag("form li label", /Meta description/)
            end

          end

        end

        describe ':hint option' do

          describe 'when provided' do

            it 'should be passed down to the paragraph tag' do
              hint_text = "this is the title of the post"
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:title, :hint => hint_text))
              end
              output_buffer.should have_tag("form li p.inline-hints", hint_text)
            end

          end

          describe 'when not provided' do

            it 'should not render a hint paragraph' do
              hint_text = "this is the title of the post"
              semantic_form_for(@new_post) do |builder| 
                concat(builder.input(:title))
              end
              output_buffer.should_not have_tag("form li p.inline-hints")
            end

          end

        end
        
      end
      
      describe ':as any type of input' do

        it 'should create a list item for each input' do
          semantic_form_for(@new_post) do |builder| 
            concat(builder.input(:title))
            concat(builder.input(:body))
          end
           output_buffer.should have_tag('form li', :count => 2)
        end
        
        describe 'when there are errors on the object for this method' do
          
          before do
            @title_errors = ['must not be blank', 'must be longer than 10 characters', 'must be awesome']
            @errors = mock('errors')
            @errors.stub!(:on).with(:title).and_return(@title_errors)
            @new_post.stub!(:errors).and_return(@errors)
          
            semantic_form_for(@new_post) do |builder| 
              concat(builder.input(:title))
            end
          end
          
          it 'should apply an errors class to the list item' do
            output_buffer.should have_tag('form li.error')
          end
          
          it 'should render a paragraph with the errors joined into a sentence' do
            output_buffer.should have_tag('form li.error p.inline-errors', @title_errors.to_sentence)
          end
          
        end
        
        describe 'when there are no errors on the object for this method' do
          
          before do
            semantic_form_for(@new_post) do |builder| 
              concat(builder.input(:title))
            end
          end
          
          it 'should not apply an errors class to the list item' do
            output_buffer.should_not have_tag('form li.error')
          end          
          
          it 'should render a paragraph for the errors' do
            output_buffer.should_not have_tag('form li.error p.inline-errors')
          end
          
        end
        
      end
      
      describe ':as => :string' do

        setup do 
          @new_post.stub!(:title)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 50))
        
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => :string))
          end
        end

        it 'should have a string class on the wrapper' do
          output_buffer.should have_tag('form li.string')
        end

        it 'should have a post_title_input id on the wrapper' do
          output_buffer.should have_tag('form li#post_title_input')
        end

        it 'should generate a label for the input' do
          output_buffer.should have_tag('form li label')
          output_buffer.should have_tag('form li label[@for="post_title"')
          output_buffer.should have_tag('form li label', /Title/)
        end

        it 'should generate a text input' do
          output_buffer.should have_tag('form li input')
          output_buffer.should have_tag('form li input#post_title')
          output_buffer.should have_tag('form li input[@type="text"]')
          output_buffer.should have_tag('form li input[@name="post[title]"]')
        end

        it 'should have a maxlength matching the column limit' do
          should_have_maxlength_matching_column_limit(:title, :string, :string)
        end

        it 'should use DEFAULT_TEXT_FIELD_SIZE for columns longer than DEFAULT_TEXT_FIELD_SIZE' do
          should_use_default_text_size_for_columns_longer_than_default(:title, :string, :string)
        end

        it 'should use the column size for columns shorter than DEFAULT_TEXT_FIELD_SIZE' do
          should_use_the_column_size_for_columns_shorter_than_default(:title, :string, :string)
        end

        it 'should use DEFAULT_TEXT_FIELD_SIZE for methods without database columns' do
          should_use_default_size_for_methods_without_columns(:string)
        end

      end
      
      describe 'for belongs_to associations' do
        
        setup do 
          @fred = mock('user')
          @fred.stub!(:to_label).and_return('Fred Smith')
          @fred.stub!(:id).and_return(37)

          @bob = mock('user')
          @bob.stub!(:to_label).and_return('Bob Rock')
          @bob.stub!(:id).and_return(42)

          Author.stub!(:find).and_return([@fred, @bob])

          @new_post.stub!(:author).and_return(@bob)
          @new_post.stub!(:author_id).and_return(@bob.id)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :integer, :limit => 255))
        end
        
        describe ':as => :radio' do

          before do 
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:author_id, :as => :radio))
            end
          end

          it 'should have a radio class on the wrapper' do
            output_buffer.should have_tag('form li.radio')
          end

          it 'should have a post_author_id_input id on the wrapper' do
            output_buffer.should have_tag('form li#post_author_id_input')
          end

          it 'should generate a fieldset and legend containing label text for the input' do
            output_buffer.should have_tag('form li fieldset')
            output_buffer.should have_tag('form li fieldset legend')
            output_buffer.should have_tag('form li fieldset legend', /Author/)
          end

          it 'should generate an ordered list with a list item for each choice' do
            output_buffer.should have_tag('form li fieldset ol')
            output_buffer.should have_tag('form li fieldset ol li', :count => Author.find(:all).size)
          end

          describe "each choice" do

            it 'should contain a label for the radio input with a nested input and label text' do
              Author.find(:all).each do |author|
                output_buffer.should have_tag('form li fieldset ol li label')
                output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
                output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_id_#{author.id}']")
                output_buffer.should have_tag("form li fieldset ol li label input")
              end
            end

            it "should have a radio input" do
              Author.find(:all).each do |author|
                output_buffer.should have_tag("form li fieldset ol li label input#post_author_id_#{author.id}")
                output_buffer.should have_tag("form li fieldset ol li label input[@type='radio']")
                output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
                output_buffer.should have_tag("form li fieldset ol li label input[@name='post[author_id]']")
              end
            end

            xit "should mark input as checked if it's the the existing choice" do
              @new_post.author_id.should == @bob.id
              @new_post.author.id.should == @bob.id
              @new_post.author.should == @bob
              semantic_form_for(@new_post) do |builder|
                concat(builder.input_style(:author_id, :as => :radio))
              end
              
              output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
            end

          end

        end
        
        describe ':as => :select' do

          before do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:author_id, :as => :select))
            end
          end

          it 'should have a select class on the wrapper' do
            output_buffer.should have_tag('form li.select')
          end
          
          it 'should have a post_author_id_input id on the wrapper' do
            output_buffer.should have_tag('form li#post_author_id_input')
          end
          
          it 'should have a label inside the wrapper' do
            output_buffer.should have_tag('form li label')
          end
          
          it 'should have a select inside the wrapper' do
            output_buffer.should have_tag('form li select')
          end
          
          it 'should have a select option for each Author' do
            output_buffer.should have_tag('form li select option', :count => Author.find(:all).size)
            Author.find(:all).each do |author|
              output_buffer.should have_tag("form li select option[@value='#{author.id}']", /#{author.to_label}/)
            end
          end
                    
        end
        
      end

      describe ':as => :password' do

        setup do 
          @new_post.stub!(:password_hash)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 50))

          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:password_hash, :as => :password))
          end
        end

        it 'should have a password class on the wrapper' do
          output_buffer.should have_tag('form li.password')
        end

        it 'should have a post_title_input id on the wrapper' do
          output_buffer.should have_tag('form li#post_password_hash_input')
        end

        it 'should generate a label for the input' do
          output_buffer.should have_tag('form li label')
          output_buffer.should have_tag('form li label[@for="post_password_hash"')
          output_buffer.should have_tag('form li label', /Password hash/)
        end

        it 'should generate a password input' do
          output_buffer.should have_tag('form li input')
          output_buffer.should have_tag('form li input#post_password_hash')
          output_buffer.should have_tag('form li input[@type="password"]')
          output_buffer.should have_tag('form li input[@name="post[password_hash]"]')
        end

        it 'should have a maxlength matching the column limit' do
          should_have_maxlength_matching_column_limit(:password_hash, :password, :string)
        end

        it 'should use DEFAULT_TEXT_FIELD_SIZE for columns longer than DEFAULT_TEXT_FIELD_SIZE' do
          should_use_default_text_size_for_columns_longer_than_default(:password_hash, :password, :string)
        end

        it 'should use the column size for columns shorter than DEFAULT_TEXT_FIELD_SIZE' do
          should_use_the_column_size_for_columns_shorter_than_default(:password_hash, :password, :string)
        end

        it 'should use DEFAULT_TEXT_FIELD_SIZE for methods without database columns' do
          should_use_default_size_for_methods_without_columns(:password)
        end

      end

      describe ':as => :text' do

        setup do 
          @new_post.stub!(:body)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :text))
          
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:body, :as => :text))
          end
        end

        it 'should have a text class on the wrapper' do
          output_buffer.should have_tag('form li.text')
        end

        it 'should have a post_title_input id on the wrapper' do
          output_buffer.should have_tag('form li#post_body_input')
        end

        it 'should generate a label for the input' do
          output_buffer.should have_tag('form li label')
          output_buffer.should have_tag('form li label[@for="post_body"')
          output_buffer.should have_tag('form li label', /Body/)
        end

        it 'should generate a text input' do
         output_buffer.should have_tag('form li textarea')
         output_buffer.should have_tag('form li textarea#post_body')
         output_buffer.should have_tag('form li textarea[@name="post[body]"]')
        end

      end

      describe ':as => :date' do
        it 'should have some specs!'
      end

      describe ':as => :datetime' do
        it 'should have some specs!'
      end

      describe ':as => :time' do
        it 'should have some specs!'
      end
      
      describe ':as => :boolean' do

        setup do 
          @new_post.stub!(:allow_comments)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
          
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:allow_comments, :as => :boolean))
          end
        end

        it 'should have a boolean class on the wrapper' do
          output_buffer.should have_tag('form li.boolean')
        end

        it 'should have a post_allow_comments_input id on the wrapper' do
          output_buffer.should have_tag('form li#post_allow_comments_input')
        end

        it 'should generate a label containing the input' do
          output_buffer.should have_tag('form li label')
          output_buffer.should have_tag('form li label[@for="post_allow_comments"')
          output_buffer.should have_tag('form li label', /Allow comments/)
          output_buffer.should have_tag('form li label input[@type="checkbox"]')
        end

        it 'should generate a checkbox input' do
          output_buffer.should have_tag('form li label input')
          output_buffer.should have_tag('form li label input#post_allow_comments')
          output_buffer.should have_tag('form li label input[@type="checkbox"]')
          output_buffer.should have_tag('form li label input[@name="post[allow_comments]"]')
        end
      
      end
      
      describe ':as => :boolean_radio' do
        
        setup do 
          @new_post.stub!(:allow_comments)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
          
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:allow_comments, :as => :boolean_radio))
          end
        end
        
        it 'should have a boolean_radio class on the wrapper' do
          output_buffer.should have_tag('form li.boolean_radio')
        end
        
        it 'should have a post_allow_comments_input id on the wrapper' do
          output_buffer.should have_tag('form li#post_allow_comments_input')
        end
        
        it 'should generate a fieldset containing a legend' do
          output_buffer.should have_tag('form li fieldset legend', /Allow comments/)
        end
        
        it 'should generate a fieldset containing an ordered list of two items with true and false classes' do
          output_buffer.should have_tag('form li fieldset ol li.true', :count => 1)
          output_buffer.should have_tag('form li fieldset ol li.false', :count => 1)
        end
                
        it 'should generate a fieldset containing two labels' do
          output_buffer.should have_tag('form li fieldset ol li label', :count => 2)
          output_buffer.should have_tag('form li fieldset ol li label', /Yes$/)
          output_buffer.should have_tag('form li fieldset ol li label', /No$/)
        end
        
        it 'should generate a fieldset containing two radio inputs' do
          output_buffer.should have_tag('form li fieldset ol li label input[@type="radio"]', :count => 2)
          output_buffer.should have_tag('form li fieldset ol li label input[@value="true"]')
          output_buffer.should have_tag('form li fieldset ol li label input[@value="false"]')
        end
        
        describe 'when the value is nil' do
          setup do 
            @new_post.stub!(:allow_comments).and_return(nil)
            @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
            
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:allow_comments, :as => :boolean_radio))
            end
          end
          
          it 'should not mark either input as checked' do
            output_buffer.should_not have_tag('form li fieldset ol li label input[@checked="checked"]')
          end
        
        end
        
        describe 'when the value is true' do
          setup do 
            @new_post.stub!(:allow_comments).and_return(true)
            @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:allow_comments, :as => :boolean_radio))
            end
          end
          it 'should mark the true input as checked' do
            output_buffer.should have_tag('form li fieldset ol li label input[@value="true"][@checked="checked"]', :count => 1)
          end
          it 'should not mark the false input as checked' do
            output_buffer.should_not have_tag('form li fieldset ol li label input[@value="false"][@checked="checked"]')
          end
        end
        
        describe 'when the value is false' do
          setup do 
            @new_post.stub!(:allow_comments).and_return(false)
            @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:allow_comments, :as => :boolean_radio))
            end
          end
          it 'should not mark the true input as checked' do
            output_buffer.should_not have_tag('form li fieldset ol li.true label input[@value="true"][@checked="checked"]', :count => 1)
          end
          it 'should mark the false input as checked' do
            output_buffer.should have_tag('form li fieldset ol li.false label input[@value="false"][@checked="checked"]')
          end
        end
        
        describe 'when :true and :false options are provided' do
          setup do 
            @new_post.stub!(:allow_comments)
            @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:allow_comments, :as => :boolean_radio, :true => "Absolutely", :false => "No Way"))
            end
          end
          it 'should pass them down to the input labels' do
            output_buffer.should have_tag('form li fieldset ol li.true label', /Absolutely$/)
            output_buffer.should have_tag('form li fieldset ol li.false label', /No Way$/)
          end
        end
      end
      
      describe ':as => :boolean_select' do
        
        setup do 
          @new_post.stub!(:allow_comments)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :boolean))
          
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:allow_comments, :as => :boolean_select))
          end
        end
        
        it 'should have a boolean_select class on the wrapper' do
          output_buffer.should have_tag('form li.boolean_select')
        end
        
        it 'should have a post_allow_comments_input id on the wrapper' do
          output_buffer.should have_tag('form li#post_allow_comments_input')
        end
        
        it 'should generate a label containing the input' do
          output_buffer.should have_tag('form li label')
          output_buffer.should have_tag('form li label[@for="post_allow_comments"')
          output_buffer.should have_tag('form li label', /Allow comments/)
        end
        
        it 'should generate a select box with two options' do
          output_buffer.should have_tag('form li select')
          output_buffer.should have_tag('form li select#post_allow_comments')
          output_buffer.should have_tag('form li select[@name="post[allow_comments]"]')
          output_buffer.should have_tag('form li select#post_allow_comments option', :count => 2)
        end
        
        describe 'when the :true and :false options are supplied' do
          
          before do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:allow_comments, :as => :boolean_select, :true => "Yes Please!", :false => "No Thanks!"))
            end
          end
          
          it 'should use the values as the text for the option tags' do
            output_buffer.should have_tag('form li select')
            output_buffer.should have_tag('form li select#post_allow_comments')
            output_buffer.should have_tag('form li select#post_allow_comments option[@value="true"]', /Yes Please\!/)
            output_buffer.should have_tag('form li select#post_allow_comments option[@value="false"]', /No Thanks\!/)
          end
          
        end
        
        describe 'when the :true and :false options are not supplied' do
          
          before do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:allow_comments, :as => :boolean_select))
            end
          end
          
          it 'should use the default values' do
            output_buffer.should have_tag('form li select')
            output_buffer.should have_tag('form li select#post_allow_comments')
            output_buffer.should have_tag('form li select#post_allow_comments option[@value="true"]', /Yes/)
            output_buffer.should have_tag('form li select#post_allow_comments option[@value="false"]', /No/)
          end
          
        end
        
      end

      describe ':as => :numeric' do

        setup do 
          @new_post.stub!(:comments_count)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :integer, :limit => 50))
          
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:comments_count, :as => :numeric))
          end
          output_buffer.should have_tag('form li.numeric')          
        end

        it 'should have a numeric class on the wrapper' do
          output_buffer.should have_tag("form li.numeric")
        end

        it 'should have a comments_count_input id on the wrapper' do
          output_buffer.should have_tag('form li#post_comments_count_input')
        end

        it 'should generate a label for the input' do
          output_buffer.should have_tag('form li label')
          output_buffer.should have_tag('form li label[@for="post_comments_count"')
          output_buffer.should have_tag('form li label', /Comments count/)
        end

        it 'should generate a text input' do
          output_buffer.should have_tag('form li input')
          output_buffer.should have_tag('form li input#post_comments_count')
          output_buffer.should have_tag('form li input[@type="text"]')
          output_buffer.should have_tag('form li input[@name="post[comments_count]"]')
        end

        it 'should have a maxlength matching the column limit' do
          should_have_maxlength_matching_column_limit(:comments_count, :numeric, :integer)
        end

        it 'should use DEFAULT_TEXT_FIELD_SIZE for columns longer than DEFAULT_TEXT_FIELD_SIZE' do
          should_use_default_text_size_for_columns_longer_than_default(:comments_count, :numeric, :integer)
        end

        it 'should use the column size for columns shorter than DEFAULT_TEXT_FIELD_SIZE' do
          should_use_the_column_size_for_columns_shorter_than_default(:comments_count, :numeric, :integer)
        end

        it 'should use DEFAULT_TEXT_FIELD_SIZE for methods without database columns' do
          should_use_default_size_for_methods_without_columns(:numeric)
        end

      end
      
    end
    
    describe '#input_field_set' do
      
      describe 'when no options are provided' do
        before do
          semantic_form_for(@new_post) do |builder|
            builder.input_field_set do
              concat('hello')
            end
          end
        end
        it 'should render a fieldset inside the form, with a class of "inputs"' do
          output_buffer.should have_tag("form fieldset.inputs")
        end
        it 'should render an ol inside the fieldset' do
          output_buffer.should have_tag("form fieldset.inputs ol")
        end
        it 'should render the contents of the block inside the ol' do
          output_buffer.should have_tag("form fieldset.inputs ol", /hello/)
        end
        it 'should not render a legend inside the fieldset' do
          output_buffer.should_not have_tag("form fieldset.inputs legend")
        end
      end
      
      describe 'when a :name option is provided' do
        before do
          @legend_text = "Advanced options"
          
          semantic_form_for(@new_post) do |builder|
            builder.input_field_set :name => @legend_text do
            end
          end
        end
        it 'should render a fieldset inside the form' do
          output_buffer.should have_tag("form fieldset legend", /#{@legend_text}/)
        end
      end
      
      describe 'when other options are provided' do
        before do
          @id_option = 'advanced'
          @class_option = 'wide'
          
          semantic_form_for(@new_post) do |builder|
            builder.input_field_set :id => @id_option, :class => @class_option do
            end
          end
        end
        it 'should pass the options into the fieldset tag as attributes' do
          output_buffer.should have_tag("form fieldset##{@id_option}")
          output_buffer.should have_tag("form fieldset.#{@class_option}")
        end
      end
      
    end
    
    describe '#button_field_set' do
      
      describe 'when no options are provided' do
        before do
          semantic_form_for(@new_post) do |builder|
            builder.button_field_set do
              concat('hello')
            end
          end
        end
        it 'should render a fieldset inside the form, with a class of "inputs"' do
          output_buffer.should have_tag("form fieldset.buttons")
        end
        it 'should render an ol inside the fieldset' do
          output_buffer.should have_tag("form fieldset.buttons ol")
        end
        it 'should render the contents of the block inside the ol' do
          output_buffer.should have_tag("form fieldset.buttons ol", /hello/)
        end
        it 'should not render a legend inside the fieldset' do
          output_buffer.should_not have_tag("form fieldset.buttons legend")
        end
      end
      
      describe 'when a :name option is provided' do
        before do
          @legend_text = "Advanced options"
          
          semantic_form_for(@new_post) do |builder|
            builder.button_field_set :name => @legend_text do
            end
          end
        end
        it 'should render a fieldset inside the form' do
          output_buffer.should have_tag("form fieldset legend", /#{@legend_text}/)
        end
      end
      
      describe 'when other options are provided' do
        before do
          @id_option = 'advanced'
          @class_option = 'wide'
          
          semantic_form_for(@new_post) do |builder|
            builder.button_field_set :id => @id_option, :class => @class_option do
            end
          end
        end
        it 'should pass the options into the fieldset tag as attributes' do
          output_buffer.should have_tag("form fieldset##{@id_option}")
          output_buffer.should have_tag("form fieldset.#{@class_option}")
        end
      end
      
    end
    
    describe '#commit_button' do
      it 'should have some specs'
    end
    
    describe '#save_or_create_commit_button_text' do
      it 'should have some specs'
    end
    
  end

end
