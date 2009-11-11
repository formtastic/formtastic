# coding: utf-8
require 'rubygems'

def smart_require(lib_name, gem_name, gem_version = '>= 0.0.0')
  begin
    require lib_name if lib_name
  rescue LoadError
    if gem_name
      gem gem_name, gem_version
      require lib_name if lib_name
    end
  end
end

smart_require 'spec', 'spec', '>= 1.2.6'
smart_require false, 'rspec-rails', '>= 1.2.6'
smart_require 'hpricot', 'hpricot', '>= 0.6.1'
smart_require 'rspec_hpricot_matchers', 'rspec_hpricot_matchers', '>= 1.0.0'
smart_require 'active_support', 'activesupport', '>= 2.3.4'
smart_require 'action_controller', 'actionpack', '>= 2.3.4'
smart_require 'action_view', 'actionpack', '>= 2.3.4'

Spec::Runner.configure do |config|
  config.include(RspecHpricotMatchers)
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'formtastic'

module FormtasticSpecHelper
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper
  include ActionView::Helpers::RecordIdentificationHelper
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::CaptureHelper
  include ActiveSupport
  include ActionController::PolymorphicRoutes
  
  include Formtastic::SemanticFormHelper
  
  def default_input_type(column_type, column_name = :generic_column_name)
    @new_post.stub!(column_name)
    @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => column_type)) unless column_type.nil?

    semantic_form_for(@new_post) do |builder|
      @default_type = builder.send(:default_input_type, column_name)
    end

    return @default_type
  end
  
  class ::Post
    def id
    end
  end
  class ::Author
  end
  
  def mock_everything
    
    # Resource-oriented styles like form_for(@post) will expect a path method for the object,
    # so we're defining some here.
    def post_path(o); "/posts/1"; end
    def posts_path; "/posts"; end
    def new_post_path; "/posts/new"; end

    def author_path(o); "/authors/1"; end
    def authors_path; "/authors"; end
    def new_author_path; "/authors/new"; end
    
    @fred = mock('user')
    @fred.stub!(:class).and_return(::Author)
    @fred.stub!(:to_label).and_return('Fred Smith')
    @fred.stub!(:login).and_return('fred_smith')
    @fred.stub!(:id).and_return(37)
    @fred.stub!(:new_record?).and_return(false)
    @fred.stub!(:errors).and_return(mock('errors', :[] => nil))

    @bob = mock('user')
    @bob.stub!(:class).and_return(::Author)
    @bob.stub!(:to_label).and_return('Bob Rock')
    @bob.stub!(:login).and_return('bob')
    @bob.stub!(:id).and_return(42)
    @bob.stub!(:posts).and_return([])
    @bob.stub!(:post_ids).and_return([])
    @bob.stub!(:new_record?).and_return(false)
    @bob.stub!(:errors).and_return(mock('errors', :[] => nil))

    ::Author.stub!(:find).and_return([@fred, @bob])
    ::Author.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Author.stub!(:human_name).and_return('::Author')
    ::Author.stub!(:reflect_on_validations_for).and_return([])
    ::Author.stub!(:reflect_on_association).and_return { |column_name| mock('reflection', :options => {}, :klass => Post, :macro => :has_many) if column_name == :posts }

    # Sometimes we need a mock @post object and some Authors for belongs_to
    @new_post = mock('post')
    @new_post.stub!(:class).and_return(::Post)
    @new_post.stub!(:id).and_return(nil)
    @new_post.stub!(:new_record?).and_return(true)
    @new_post.stub!(:errors).and_return(mock('errors', :[] => nil))
    @new_post.stub!(:author).and_return(nil)

    @freds_post = mock('post')
    @freds_post.stub!(:class).and_return(::Post)
    @freds_post.stub!(:to_label).and_return('Fred Smith')
    @freds_post.stub!(:id).and_return(19)
    @freds_post.stub!(:author).and_return(@fred)
    @freds_post.stub!(:author_id).and_return(@fred.id)
    @freds_post.stub!(:authors).and_return([@fred])
    @freds_post.stub!(:author_ids).and_return([@fred.id])
    @freds_post.stub!(:new_record?).and_return(false)
    @freds_post.stub!(:errors).and_return(mock('errors', :[] => nil))
    @fred.stub!(:posts).and_return([@freds_post])
    @fred.stub!(:post_ids).and_return([@freds_post.id])

    ::Post.stub!(:human_attribute_name).and_return { |column_name| column_name.humanize }
    ::Post.stub!(:human_name).and_return('Post')
    ::Post.stub!(:reflect_on_all_validations).and_return([])
    ::Post.stub!(:reflect_on_validations_for).and_return([])
    ::Post.stub!(:reflect_on_association).and_return do |column_name|
      case column_name
      when :author, :author_status
        mock('reflection', :options => {}, :klass => ::Author, :macro => :belongs_to)
      when :authors
        mock('reflection', :options => {}, :klass => ::Author, :macro => :has_and_belongs_to_many)
      end
    end
    ::Post.stub!(:find).and_return([@freds_post])
    
    @new_post.stub!(:title)
    @new_post.stub!(:body)
    @new_post.stub!(:published)
    @new_post.stub!(:column_for_attribute).with(:meta_description).and_return(mock('column', :type => :string, :limit => 255))
    @new_post.stub!(:column_for_attribute).with(:title).and_return(mock('column', :type => :string, :limit => 255))
    @new_post.stub!(:column_for_attribute).with(:body).and_return(mock('column', :type => :text))
    @new_post.stub!(:column_for_attribute).with(:published).and_return(mock('column', :type => :boolean))
  end
  
  def self.included(base)
    base.class_eval do
      
      attr_accessor :output_buffer
      
      def protect_against_forgery?
        false
      end
      
    end
  end
  
end

::ActiveSupport::Deprecation.silenced = true
