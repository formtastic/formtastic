# encoding: utf-8
require 'spec_helper'

describe 'FormHelper' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe '#semantic_form_for' do

    it 'yields an instance of Formtastic::FormBuilder' do
      semantic_form_for(@new_post, :url => '/hello') do |builder|
        builder.class.should == Formtastic::FormBuilder
      end
    end

    it 'adds a class of "formtastic" to the generated form' do
      concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.formtastic")
    end

    it 'adds a "novalidate" attribute to the generated form when configured to do so' do
      with_config :perform_browser_validations, true do
        concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
        end)
        output_buffer.should_not have_tag("form[@novalidate]")
      end
    end

    it 'omits a "novalidate" attribute to the generated form when configured to do so' do
      with_config :perform_browser_validations, false do
        concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
        end)
        output_buffer.should have_tag("form[@novalidate]")
      end
    end

    it 'allows form HTML to override "novalidate" attribute when configure to not show' do
      with_config :perform_browser_validations, false do
        concat(semantic_form_for(@new_post, :url => '/hello', :html => { :novalidate => true }) do |builder|
        end)
        output_buffer.should have_tag("form[@novalidate]")
      end
    end

    it 'allows form HTML to override "novalidate" attribute when configure to show' do
      with_config :perform_browser_validations, true do
        concat(semantic_form_for(@new_post, :url => '/hello', :html => { :novalidate => false }) do |builder|
        end)
        output_buffer.should_not have_tag("form[@novalidate]")
      end
    end

    it 'adds a class of "xyz" to the generated form' do
      Formtastic::Helpers::FormHelper.default_form_class = 'xyz'
      concat(semantic_form_for(::Post.new, :as => :post, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.xyz")
    end

    it 'omits the leading spaces from the classes in the generated form when the default class is nil' do
      Formtastic::Helpers::FormHelper.default_form_class = nil
      concat(semantic_form_for(::Post.new, :as => :post, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form[class='post']")
    end

    it 'adds class matching the object name to the generated form when a symbol is provided' do
      concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.post")

      concat(semantic_form_for(:project, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.project")
    end

    it 'adds class matching the :as option when provided' do
      concat(semantic_form_for(@new_post, :as => :message, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.message")

      concat(semantic_form_for([:admins, @new_post], :as => :message, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.message")
    end

    it 'adds class matching the object\'s class to the generated form when an object is provided' do
      concat(semantic_form_for(@new_post) do |builder|
      end)
      output_buffer.should have_tag("form.post")
    end

    it 'adds a namespaced class to the generated form' do
      concat(semantic_form_for(::Namespaced::Post.new, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.namespaced_post")
    end

    it 'adds a customized class to the generated form' do
      Formtastic::Helpers::FormHelper.default_form_model_class_proc = lambda { |model_class_name| "#{model_class_name}_form" }
      concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.post_form")

      concat(semantic_form_for(:project, :url => '/hello') do |builder|
      end)
      output_buffer.should have_tag("form.project_form")
    end

    describe 'allows :html options' do
      before(:each) do
        concat(semantic_form_for(@new_post, :url => '/hello', :html => { :id => "something-special", :class => "something-extra", :multipart => true }) do |builder|
        end)
      end

      it 'to add a id of "something-special" to generated form' do
        output_buffer.should have_tag("form#something-special")
      end

      it 'to add a class of "something-extra" to generated form' do
        output_buffer.should have_tag("form.something-extra")
      end

      it 'to add enctype="multipart/form-data"' do
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
      semantic_form_for(@new_post, :as => :post, :url => new_post_path) do |builder|
        builder.object.class.should == ::Post
        builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
      end
    end

    it 'can be called with a generic style and inline object' do
      semantic_form_for(@new_post, :url => new_post_path) do |builder|
        builder.object.class.should == ::Post
        builder.object_name.to_s.should == "post" # TODO: is this forced .to_s a bad assumption somewhere?
      end
    end

    describe 'ActionView::Base.field_error_proc' do
      it 'is set to no-op wrapper by default' do
        semantic_form_for(@new_post, :url => '/hello') do |builder|
          ::ActionView::Base.field_error_proc.call("html", nil).should == "html"
        end
      end

      it 'is set to the configured custom field_error_proc' do
        field_error_proc = double()
        Formtastic::Helpers::FormHelper.formtastic_field_error_proc = field_error_proc
        semantic_form_for(@new_post, :url => '/hello') do |builder|
          ::ActionView::Base.field_error_proc.should == field_error_proc
        end
      end

      it 'is restored to its original value after the form is rendered' do
        lambda do
          Formtastic::Helpers::FormHelper.formtastic_field_error_proc = proc {""}
          semantic_form_for(@new_post, :url => '/hello') { |builder| }
        end.should_not change(::ActionView::Base, :field_error_proc)
      end
    end

    describe "with :builder option" do
      it "yields an instance of the given builder" do
        class MyAwesomeCustomBuilder < Formtastic::FormBuilder
        end
        semantic_form_for(@new_post, :url => '/hello', :builder => MyAwesomeCustomBuilder) do |builder|
          builder.class.should == MyAwesomeCustomBuilder
        end
      end
    end

    describe 'with :namespace option' do
      it "should set the custom_namespace" do
        semantic_form_for(@new_post, :namespace => 'context2') do |builder|
          builder.custom_namespace == 'context2'
        end
      end
    end

  end

  describe '#semantic_fields_for' do
    it 'yields an instance of Formtastic::FormBuilder' do
      semantic_fields_for(@new_post) do |builder|
        builder.class.should.kind_of?(Formtastic::FormBuilder)
      end
    end
  end

end

