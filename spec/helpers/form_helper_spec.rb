# encoding: utf-8
require 'spec_helper'

RSpec.describe 'FormHelper' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe '#semantic_form_for' do

    it 'yields an instance of Formtastic::FormBuilder' do
      semantic_form_for(@new_post, :url => '/hello') do |builder|
        expect(builder.class).to eq(Formtastic::FormBuilder)
      end
    end

    it 'adds a class of "formtastic" to the generated form' do
      concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.formtastic")
    end

    it 'does not add "novalidate" attribute to the generated form when configured to do so' do
      with_config :perform_browser_validations, true do
        concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
        end)
        expect(output_buffer).not_to have_tag("form[@novalidate]")
      end
    end

    it 'adds "novalidate" attribute to the generated form when configured to do so' do
      with_config :perform_browser_validations, false do
        concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
        end)
        expect(output_buffer).to have_tag("form[@novalidate]")
      end
    end

    it 'allows form HTML to override "novalidate" attribute when configured to validate' do
      with_config :perform_browser_validations, false do
        concat(semantic_form_for(@new_post, :url => '/hello', :html => { :novalidate => true }) do |builder|
        end)
        expect(output_buffer).to have_tag("form[@novalidate]")
      end
    end

    it 'allows form HTML to override "novalidate" attribute when configured to not validate' do
      with_config :perform_browser_validations, true do
        concat(semantic_form_for(@new_post, :url => '/hello', :html => { :novalidate => false }) do |builder|
        end)
        expect(output_buffer).not_to have_tag("form[@novalidate]")
      end
    end

    it 'adds a class of "xyz" to the generated form' do
      Formtastic::Helpers::FormHelper.default_form_class = 'xyz'
      concat(semantic_form_for(::Post.new, :as => :post, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.xyz")
    end

    it 'omits the leading spaces from the classes in the generated form when the default class is nil' do
      Formtastic::Helpers::FormHelper.default_form_class = nil
      concat(semantic_form_for(::Post.new, :as => :post, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form[class='post']")
    end

    it 'adds class matching the object name to the generated form when a symbol is provided' do
      concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.post")

      concat(semantic_form_for(:project, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.project")
    end

    it 'adds class matching the :as option when provided' do
      concat(semantic_form_for(@new_post, :as => :message, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.message")

      concat(semantic_form_for([:admins, @new_post], :as => :message, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.message")
    end

    it 'adds class matching the object\'s class to the generated form when an object is provided' do
      concat(semantic_form_for(@new_post) do |builder|
      end)
      expect(output_buffer).to have_tag("form.post")
    end

    it 'adds a namespaced class to the generated form' do
      concat(semantic_form_for(::Namespaced::Post.new, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.namespaced_post")
    end

    it 'adds a customized class to the generated form' do
      Formtastic::Helpers::FormHelper.default_form_model_class_proc = lambda { |model_class_name| "#{model_class_name}_form" }
      concat(semantic_form_for(@new_post, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.post_form")

      concat(semantic_form_for(:project, :url => '/hello') do |builder|
      end)
      expect(output_buffer).to have_tag("form.project_form")
    end

    describe 'allows :html options' do
      before(:example) do
        concat(semantic_form_for(@new_post, :url => '/hello', :html => { :id => "something-special", :class => "something-extra", :multipart => true }) do |builder|
        end)
      end

      it 'to add a id of "something-special" to generated form' do
        expect(output_buffer).to have_tag("form#something-special")
      end

      it 'to add a class of "something-extra" to generated form' do
        expect(output_buffer).to have_tag("form.something-extra")
      end

      it 'to add enctype="multipart/form-data"' do
        expect(output_buffer).to have_tag('form[@enctype="multipart/form-data"]')
      end
    end

    it 'can be called with a resource-oriented style' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.object.class).to eq(::Post)
        expect(builder.object_name).to eq("post")
      end
    end

    it 'can be called with a generic style and instance variable' do
      semantic_form_for(@new_post, :as => :post, :url => new_post_path) do |builder|
        expect(builder.object.class).to eq(::Post)
        expect(builder.object_name.to_s).to eq("post") # TODO: is this forced .to_s a bad assumption somewhere?
      end
    end

    it 'can be called with a generic style and inline object' do
      semantic_form_for(@new_post, :url => new_post_path) do |builder|
        expect(builder.object.class).to eq(::Post)
        expect(builder.object_name.to_s).to eq("post") # TODO: is this forced .to_s a bad assumption somewhere?
      end
    end

    describe 'ActionView::Base.field_error_proc' do
      it 'is set to no-op wrapper by default' do
        semantic_form_for(@new_post, :url => '/hello') do |builder|
          expect(::ActionView::Base.field_error_proc.call("html", nil)).to eq("html")
        end
      end

      it 'is set to the configured custom field_error_proc' do
        field_error_proc = double()
        Formtastic::Helpers::FormHelper.formtastic_field_error_proc = field_error_proc
        semantic_form_for(@new_post, :url => '/hello') do |builder|
          expect(::ActionView::Base.field_error_proc).to eq(field_error_proc)
        end
      end

      it 'is restored to its original value after the form is rendered' do
        expect do
          Formtastic::Helpers::FormHelper.formtastic_field_error_proc = proc {""}
          semantic_form_for(@new_post, :url => '/hello') { |builder| }
        end.not_to change(::ActionView::Base, :field_error_proc)
      end
    end

    describe "with :builder option" do
      it "yields an instance of the given builder" do
        class MyAwesomeCustomBuilder < Formtastic::FormBuilder
        end
        semantic_form_for(@new_post, :url => '/hello', :builder => MyAwesomeCustomBuilder) do |builder|
          expect(builder.class).to eq(MyAwesomeCustomBuilder)
        end
      end
    end

    describe 'with :namespace option' do
      it "should set the custom_namespace" do
        semantic_form_for(@new_post, :namespace => 'context2') do |builder|
          expect(builder.dom_id_namespace).to eq('context2')
        end
      end
    end

    describe 'without :namespace option' do
      it 'defaults to class settings' do
        expect(Formtastic::FormBuilder).to receive(:custom_namespace).and_return('context2')

        semantic_form_for(@new_post) do |builder|
          expect(builder.dom_id_namespace).to eq('context2')
        end
      end
    end

  end

  describe '#semantic_fields_for' do
    it 'yields an instance of Formtastic::FormBuilder' do
      semantic_fields_for(@new_post) do |builder|
        expect(builder.class).to be(Formtastic::FormBuilder)
      end
    end
  end

end

