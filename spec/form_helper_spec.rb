# coding: utf-8
require 'spec_helper'

describe 'SemanticFormHelper' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end
  
  describe '#semantic_form_for' do

    it 'yields an instance of SemanticFormBuilder' do
      semantic_form_for(@new_post, :url => '/hello') do |builder|
        builder.class.should == ::Formtastic::SemanticFormBuilder
      end
    end

    it 'adds a class of "formtastic" to the generated form' do
      form = semantic_form_for(@new_post, :url => '/hello') do |builder|
      end
      output_buffer.concat(form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("form.formtastic")
    end

    it 'adds class matching the object name to the generated form when a symbol is provided' do
      form = semantic_form_for(@new_post, :url => '/hello') do |builder|
      end
      output_buffer.concat(form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("form.post")

      form = semantic_form_for(:project, :url => '/hello') do |builder|
      end
      output_buffer.concat(form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("form.project")
    end

    it 'adds class matching the object\'s class to the generated form when an object is provided' do
      form = semantic_form_for(@new_post) do |builder|
      end
      output_buffer.concat(form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("form.post")
    end

    it 'adds a namespaced class to the generated form' do
      form = semantic_form_for(::Namespaced::Post.new, :url => '/hello') do |builder|
      end
      output_buffer.concat(form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("form.namespaced_post")
    end

    describe 'allows :html options' do
      before(:each) do
         @form = semantic_form_for(@new_post, :url => '/hello', :html => { :id => "something-special", :class => "something-extra", :multipart => true }) do |builder|
        end
      end

      it 'to add a id of "something-special" to generated form' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag("form#something-special")
      end

      it 'to add a class of "something-extra" to generated form' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag("form.something-extra")
      end

      it 'to add enctype="multipart/form-data"' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('form[@enctype="multipart/form-data"]')
      end
    end

    it 'can be called with a resource-oriented style' do
      semantic_form_for(@new_post) do |builder|
        builder.object.class.should == ::Post
        builder.object_name.should == "post"
      end
    end
    
    it 'can be called with a generic style and instance variable' do
      if rails3?
        semantic_form_for(@new_post, :as => :post, :url => new_post_path) do |builder|
          builder.object.class.should == ::Post
          builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
        end
      end
      if rails2?
        semantic_form_for(:post, @new_post, :url => new_post_path) do |builder|
          builder.object.class.should == ::Post
          builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
        end
      end
    end

    it 'can be called with a generic style and inline object' do
      semantic_form_for(@new_post, :url => new_post_path) do |builder|
        builder.object.class.should == ::Post
        builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
      end
    end
    
    describe "with :builder option" do
      it "yields an instance of the given builder" do
        class MyAwesomeCustomBuilder < ::Formtastic::SemanticFormBuilder
        end
        semantic_form_for(@new_post, :url => '/hello', :builder => MyAwesomeCustomBuilder) do |builder|
          builder.class.should == MyAwesomeCustomBuilder
        end
      end
    end
    
  end

  describe '#semantic_fields_for' do
    it 'yields an instance of SemanticFormBuilder' do
      semantic_fields_for(@new_post, :url => '/hello') do |builder|
        builder.class.should == ::Formtastic::SemanticFormBuilder
      end
    end
  end

  describe '#semantic_form_remote_for' do
    it 'yields an instance of SemanticFormBuilder' do
      semantic_form_remote_for(@new_post, :url => '/hello') do |builder|
        builder.class.should == ::Formtastic::SemanticFormBuilder
      end
    end
  end

  describe '#semantic_form_for_remote' do
    it 'yields an instance of SemanticFormBuilder' do
      semantic_remote_form_for(@new_post, :url => '/hello') do |builder|
        builder.class.should == ::Formtastic::SemanticFormBuilder
      end
    end
  end

end

