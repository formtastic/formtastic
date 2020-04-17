# encoding: utf-8
require 'rubygems'
require 'bundler/setup'
require 'active_support'
require 'action_pack'
require 'action_view'
require 'action_controller'
require 'action_dispatch'
require 'active_record'

ActiveRecord::Base.establish_connection('url' => 'sqlite3::memory:', 'pool' => 1)
load 'spec/schema.rb'

require File.expand_path(File.join(File.dirname(__FILE__), '../lib/formtastic'))

require 'ammeter/init'

# Requires supporting files with custom matchers and macros, etc,
# in ./support/ and its subdirectories in alphabetic order.
Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].sort.each {|f| require f}

I18n.enforce_available_locales = false if I18n.respond_to?(:enforce_available_locales)

module FakeHelpersModule
end

module FormtasticSpecHelper
  include ActionPack
  include ActionView::Context if defined?(ActionView::Context)
  include ActionController::RecordIdentifier if defined?(ActionController::RecordIdentifier)
  include ActionView::Helpers::FormHelper
  include ActionView::Helpers::FormTagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::ActiveRecordHelper if defined?(ActionView::Helpers::ActiveRecordHelper)
  include ActionView::Helpers::ActiveModelHelper if defined?(ActionView::Helpers::ActiveModelHelper)
  include ActionView::Helpers::DateHelper
  include ActionView::Helpers::CaptureHelper
  include ActionView::Helpers::AssetTagHelper
  include ActiveSupport
  include ActionController::PolymorphicRoutes if defined?(ActionController::PolymorphicRoutes)
  include ActionDispatch::Routing::PolymorphicRoutes 
  include AbstractController::UrlFor if defined?(AbstractController::UrlFor)
  include ActionView::RecordIdentifier if defined?(ActionView::RecordIdentifier)
  
  include Formtastic::Helpers::FormHelper

  def default_input_type(column_type, column_name = :generic_column_name)
    allow(@new_post).to receive(column_name)
    allow(@new_post).to receive(:column_for_attribute).and_return(double('column', :type => column_type)) unless column_type.nil?

    semantic_form_for(@new_post) do |builder|
      @default_type = builder.send(:default_input_type, column_name)
    end

    return @default_type
  end

  def active_model_validator(kind, attributes, options = {})
    validator = double("ActiveModel::Validations::#{kind.to_s.titlecase}Validator", :attributes => attributes, :options => options)
    allow(validator).to receive(:kind).and_return(kind)
    validator
  end

  def active_model_presence_validator(attributes, options = {})
    active_model_validator(:presence, attributes, options)
  end

  def active_model_length_validator(attributes, options = {})
    active_model_validator(:length, attributes, options)
  end

  def active_model_inclusion_validator(attributes, options = {})
    active_model_validator(:inclusion, attributes, options)
  end

  def active_model_numericality_validator(attributes, options = {})
    active_model_validator(:numericality, attributes, options)
  end

  class ::MongoPost
    include MongoMapper::Document if defined?(MongoMapper::Document)

    def id
    end

    def persisted?
    end
  end


  class ::Post
    extend ActiveModel::Naming if defined?(ActiveModel::Naming)
    include ActiveModel::Conversion if defined?(ActiveModel::Conversion)

    def id
    end

    def persisted?
    end
  end

  module ::Namespaced
    class Post < ActiveRecord::Base
    end
  end

  class ::Author < ActiveRecord::Base
    def new_record?
      !id
    end

    def to_label
      [name, surname].compact.join(' ')
    end
  end

  class ::HashBackedAuthor < Hash
    extend ActiveModel::Naming if defined?(ActiveModel::Naming)
    include ActiveModel::Conversion if defined?(ActiveModel::Conversion)
    def persisted?; false; end
    def name
      'hash backed author'
    end
  end

  class ::LegacyPost < ActiveRecord::Base
     belongs_to :author, foreign_key: :post_author
  end

  class ::Continent
    extend ActiveModel::Naming if defined?(ActiveModel::Naming)
    include ActiveModel::Conversion if defined?(ActiveModel::Conversion)
  end

  class ::PostModel
    extend ActiveModel::Naming if defined?(ActiveModel::Naming)
    include ActiveModel::Conversion if defined?(ActiveModel::Conversion)
  end

  ##
  # We can't mock :respond_to?, so we need a concrete class override
  class ::MongoidReflectionMock < RSpec::Mocks::Double
    def initialize(name=nil, stubs_and_options={})
      super name, stubs_and_options
    end

    def respond_to?(sym)
      sym == :options ? false : super
    end
  end
  
  # Model.all returns an association proxy, which quacks a lot like an array.
  # We use this in stubs or mocks where we need to return the later.
  # 
  # TODO try delegate?
  # delegate :map, :size, :length, :first, :to_ary, :each, :include?, :to => :array
  class MockScope
    attr_reader :array
    
    def initialize(the_array)
      @array = the_array
    end
    
    def map(&block)
      array.map(&block)
    end
    
    def where(*args)
      # array
      self
    end
    
    def includes(*args)
      self
    end
    
    def size
      array.size
    end
    alias_method :length, :size
    
    def first
      array.first
    end
    
    def to_ary
      array
    end
    
    def each(&block)
      array.each(&block)
    end
    
    def include?(*args)
      array.include?(*args)
    end
  end

  def _routes
    url_helpers = double('url_helpers')
    allow(url_helpers).to receive(:hash_for_posts_path).and_return({})
    allow(url_helpers).to receive(:hash_for_post_path).and_return({})
    allow(url_helpers).to receive(:hash_for_post_models_path).and_return({})
    allow(url_helpers).to receive(:hash_for_authors_path).and_return({})

    double('_routes',
      :url_helpers => url_helpers,
      :url_for => "/mock/path",
      :polymorphic_mappings => {}
    )
  end

  def controller
    env = double('env', :[] => nil)
    request = double('request', :env => env)
    double('controller', :controller_path= => '', :params => {}, :request => request)
  end

  def default_url_options
    {}
  end

  def mock_everything

    # Resource-oriented styles like form_for(@post) will expect a path method for the object,
    # so we're defining some here.
    def post_models_path(*args); "/postmodels/1"; end

    def post_path(*args); "/posts/1"; end
    def posts_path(*args); "/posts"; end
    def new_post_path(*args); "/posts/new"; end

    def author_path(*args); "/authors/1"; end
    def authors_path(*args); "/authors"; end
    def new_author_path(*args); "/authors/new"; end
    
    def author_array_or_scope(the_array = [@fred, @bob])
      MockScope.new(the_array)
    end

    @fred = ::Author.new(login: 'fred_smith', age: 27, name: 'Fred', id: 37)
    @bob = ::Author.new(login: 'bob', age: 43, name: 'Bob', id: 42)
    @james = ::Author.new(age: 38, id: 75)

    allow(::Author).to receive(:scoped).and_return(::Author)
    allow(::Author).to receive(:find).and_return(author_array_or_scope)
    allow(::Author).to receive(:all).and_return(author_array_or_scope)
    allow(::Author).to receive(:where).and_return(author_array_or_scope)
    allow(::Author).to receive(:human_attribute_name) { |column_name| column_name.humanize }
    allow(::Author).to receive(:human_name).and_return('::Author')
    allow(::Author).to receive(:reflect_on_association) { |column_name| double('reflection', :options => {}, :klass => Post, :macro => :has_many) if column_name == :posts }
    allow(::Author).to receive(:content_columns).and_return([double('column', :name => 'login'), double('column', :name => 'created_at')])
    allow(::Author).to receive(:to_key).and_return(nil)
    allow(::Author).to receive(:persisted?).and_return(nil)

    @hash_backed_author = HashBackedAuthor.new

    # Sometimes we need a mock @post object and some Authors for belongs_to
    @new_post = double('post')
    allow(@new_post).to receive(:class).and_return(::Post)
    allow(@new_post).to receive(:id).and_return(nil)
    allow(@new_post).to receive(:new_record?).and_return(true)
    allow(@new_post).to receive(:errors).and_return(double('errors', :[] => nil))
    allow(@new_post).to receive(:author).and_return(nil)
    allow(@new_post).to receive(:author_attributes=).and_return(nil)
    allow(@new_post).to receive(:authors).and_return(author_array_or_scope([@fred]))
    allow(@new_post).to receive(:authors_attributes=)
    allow(@new_post).to receive(:reviewer).and_return(nil)
    allow(@new_post).to receive(:main_post).and_return(nil)
    allow(@new_post).to receive(:sub_posts).and_return([]) #TODO should be a mock with methods for adding sub posts
    allow(@new_post).to receive(:to_key).and_return(nil)
    allow(@new_post).to receive(:to_model).and_return(@new_post)
    allow(@new_post).to receive(:persisted?).and_return(nil)
    allow(@new_post).to receive(:model_name){ @new_post.class.model_name}

    @freds_post = double('post')
    allow(@freds_post).to receive(:to_ary)
    allow(@freds_post).to receive(:class).and_return(::Post)
    allow(@freds_post).to receive(:to_label).and_return('Fred Smith')
    allow(@freds_post).to receive(:id).and_return(19)
    allow(@freds_post).to receive(:title).and_return("Hello World")
    allow(@freds_post).to receive(:author).and_return(@fred)
    allow(@freds_post).to receive(:author_id).and_return(@fred.id)
    allow(@freds_post).to receive(:authors).and_return([@fred])
    allow(@freds_post).to receive(:author_ids).and_return([@fred.id])
    allow(@freds_post).to receive(:new_record?).and_return(false)
    allow(@freds_post).to receive(:errors).and_return(double('errors', :[] => nil))
    allow(@freds_post).to receive(:to_key).and_return(nil)
    allow(@freds_post).to receive(:persisted?).and_return(nil)
    allow(@freds_post).to receive(:model_name){ @freds_post.class.model_name}
    allow(@freds_post).to receive(:to_model).and_return(@freds_post)
    allow(@fred).to receive(:posts).and_return(author_array_or_scope([@freds_post]))
    allow(@fred).to receive(:post_ids).and_return([@freds_post.id])

    allow(::Post).to receive(:scoped).and_return(::Post)
    allow(::Post).to receive(:human_attribute_name) { |column_name| column_name.humanize }
    allow(::Post).to receive(:human_name).and_return('Post')
    allow(::Post).to receive(:reflect_on_all_validations).and_return([])
    allow(::Post).to receive(:reflect_on_validations_for).and_return([])
    allow(::Post).to receive(:reflections).and_return({})
    allow(::Post).to receive(:reflect_on_association) { |column_name|
      case column_name
      when :author, :author_status
        mock = double('reflection', :options => {}, :klass => ::Author, :macro => :belongs_to)
        allow(mock).to receive(:[]).with(:class_name).and_return("Author")
        mock
      when :reviewer
        mock = double('reflection', :options => {:class_name => 'Author'}, :klass => ::Author, :macro => :belongs_to)
        allow(mock).to receive(:[]).with(:class_name).and_return("Author")
        mock
      when :authors
        double('reflection', :options => {}, :klass => ::Author, :macro => :has_and_belongs_to_many)
      when :sub_posts
        double('reflection', :options => {}, :klass => ::Post, :macro => :has_many)
      when :main_post
        double('reflection', :options => {}, :klass => ::Post, :macro => :belongs_to)
      when :mongoid_reviewer
        ::MongoidReflectionMock.new('reflection',
             :options => Proc.new { raise NoMethodError, "Mongoid has no reflection.options" },
             :klass => ::Author, :macro => :referenced_in, :foreign_key => "reviewer_id") # custom id
      end
    }
    allow(::Post).to receive(:find).and_return(author_array_or_scope([@freds_post]))
    allow(::Post).to receive(:all).and_return(author_array_or_scope([@freds_post]))
    allow(::Post).to receive(:where).and_return(author_array_or_scope([@freds_post]))
    allow(::Post).to receive(:content_columns).and_return([double('column', :name => 'title'), double('column', :name => 'body'), double('column', :name => 'created_at')])
    allow(::Post).to receive(:to_key).and_return(nil)
    allow(::Post).to receive(:persisted?).and_return(nil)
    allow(::Post).to receive(:to_ary)

    allow(::MongoPost).to receive(:human_attribute_name) { |column_name| column_name.humanize }
    allow(::MongoPost).to receive(:human_name).and_return('MongoPost')
    allow(::MongoPost).to receive(:associations).and_return({
      :sub_posts => double('reflection', :options => {:polymorphic => true}, :klass => ::MongoPost, :macro => :has_many),
      :options => []
    })
    allow(::MongoPost).to receive(:find).and_return(author_array_or_scope([@freds_post]))
    allow(::MongoPost).to receive(:all).and_return(author_array_or_scope([@freds_post]))
    allow(::MongoPost).to receive(:where).and_return(author_array_or_scope([@freds_post]))
    allow(::MongoPost).to receive(:to_key).and_return(nil)
    allow(::MongoPost).to receive(:persisted?).and_return(nil)
    allow(::MongoPost).to receive(:to_ary)
    allow(::MongoPost).to receive(:model_name).and_return( double(:model_name_mock, :singular => "post", :plural => "posts", :param_key => "post", :route_key => "posts", :name => "post") )

    @new_mm_post = double('mm_post')
    allow(@new_mm_post).to receive(:class).and_return(::MongoPost)
    allow(@new_mm_post).to receive(:id).and_return(nil)
    allow(@new_mm_post).to receive(:new_record?).and_return(true)
    allow(@new_mm_post).to receive(:errors).and_return(double('errors', :[] => nil))
    allow(@new_mm_post).to receive(:title).and_return("Hello World")
    allow(@new_mm_post).to receive(:sub_posts).and_return([]) #TODO should be a mock with methods for adding sub posts
    allow(@new_mm_post).to receive(:to_key).and_return(nil)
    allow(@new_mm_post).to receive(:to_model).and_return(@new_mm_post)
    allow(@new_mm_post).to receive(:persisted?).and_return(nil)
    allow(@new_mm_post).to receive(:model_name).and_return(::MongoPost.model_name)

    @mock_file = double('file')
    Formtastic::FormBuilder.file_methods.each do |method|
      allow(@mock_file).to receive(method).and_return(true)
    end

    allow(@new_post).to receive(:title)
    allow(@new_post).to receive(:email)
    allow(@new_post).to receive(:url)
    allow(@new_post).to receive(:phone)
    allow(@new_post).to receive(:search)
    allow(@new_post).to receive(:to_ary)
    allow(@new_post).to receive(:body)
    allow(@new_post).to receive(:published)
    allow(@new_post).to receive(:publish_at)
    allow(@new_post).to receive(:created_at)
    allow(@new_post).to receive(:secret).and_return(1)
    allow(@new_post).to receive(:url)
    allow(@new_post).to receive(:email)
    allow(@new_post).to receive(:color)
    allow(@new_post).to receive(:search)
    allow(@new_post).to receive(:phone)
    allow(@new_post).to receive(:time_zone)
    allow(@new_post).to receive(:category_name)
    allow(@new_post).to receive(:allow_comments).and_return(true)
    allow(@new_post).to receive(:answer_comments)
    allow(@new_post).to receive(:country)
    allow(@new_post).to receive(:country_subdivision)
    allow(@new_post).to receive(:country_code)
    allow(@new_post).to receive(:document).and_return(@mock_file)
    allow(@new_post).to receive(:column_for_attribute).with(:meta_description).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:title).and_return(double('column', :type => :string, :limit => 50))
    allow(@new_post).to receive(:column_for_attribute).with(:body).and_return(double('column', :type => :text))
    allow(@new_post).to receive(:column_for_attribute).with(:published).and_return(double('column', :type => :boolean))
    allow(@new_post).to receive(:column_for_attribute).with(:publish_at).and_return(double('column', :type => :date))
    allow(@new_post).to receive(:column_for_attribute).with(:time_zone).and_return(double('column', :type => :string))
    allow(@new_post).to receive(:column_for_attribute).with(:allow_comments).and_return(double('column', :type => :boolean))
    allow(@new_post).to receive(:column_for_attribute).with(:author).and_return(double('column', :type => :integer))
    allow(@new_post).to receive(:column_for_attribute).with(:country).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:country_subdivision).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:country_code).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:email).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:color).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:url).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:phone).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:search).and_return(double('column', :type => :string, :limit => 255))
    allow(@new_post).to receive(:column_for_attribute).with(:document).and_return(nil)

    allow(@new_post).to receive(:author).and_return(@bob)
    allow(@new_post).to receive(:author_id).and_return(@bob.id)

    allow(@new_post).to receive(:reviewer).and_return(@fred)
    allow(@new_post).to receive(:reviewer_id).and_return(@fred.id)

    # @new_post.should_receive(:publish_at=).at_least(:once)
    allow(@new_post).to receive(:publish_at=)
    # @new_post.should_receive(:title=).at_least(:once)
    allow(@new_post).to receive(:title=)
    allow(@new_post).to receive(:main_post_id).and_return(nil)

  end

  def self.included(base)
    base.class_eval do

      attr_accessor :output_buffer

      def protect_against_forgery?
        false
      end

      def _helpers
        FakeHelpersModule
      end

    end
  end

  def with_config(config_method_name, value, &block)
    old_value = Formtastic::FormBuilder.send(config_method_name)
    Formtastic::FormBuilder.send(:"#{config_method_name}=", value)
    yield
    Formtastic::FormBuilder.send(:"#{config_method_name}=", old_value)
  end
  
  RSpec::Matchers.define :errors_matcher do |expected|
    match { |actual| actual.to_s == expected.to_s }
  end
end

class ::ActionView::Base
  include Formtastic::Helpers::FormHelper
end

::ActiveSupport::Deprecation.silenced = false

RSpec.configure do |config|
  config.infer_spec_type_from_file_location!

  config.filter_run focus: true
  config.filter_run_excluding skip: true
  config.run_all_when_everything_filtered = true

  config.before(:example) do
    Formtastic::Localizer.cache.clear!    
  end
end
