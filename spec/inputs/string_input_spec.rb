# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'string input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  describe "when object is provided" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :string))
      end)
    end

    it_should_have_input_wrapper_with_class(:string)
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_class(:stringish)
    it_should_have_input_wrapper_with_id("post_title_input")
    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("post_title")
    it_should_have_input_with_id("post_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("post[title]")
    it_should_have_maxlength_matching_column_limit
    it_should_use_default_text_field_size_when_not_nil(:string)
    it_should_not_use_default_text_field_size_when_nil(:string)
    it_should_apply_custom_input_attributes_when_input_html_provided(:string)
    it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
    it_should_apply_error_logic_for_input_type(:string)

    def input_field_for_method_should_have_maxlength(method, maxlength)
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(method))
      end)
      expect(output_buffer.to_str).to have_tag("form li input[@maxlength='#{maxlength}']")
    end

    describe 'and its a ActiveModel' do
      let(:default_maxlength) { 50 }

      before do
        allow(@new_post).to receive(:class).and_return(::PostModel)
      end

      after do
        allow(@new_post).to receive(:class).and_return(::Post)
      end

      describe 'and validates_length_of was called for the method' do
        def should_have_maxlength(maxlength, options)
          expect(@new_post.class).to receive(:validators_on).with(:title).at_least(1).and_return([
            active_model_length_validator([:title], options[:options])
          ])

          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title))
          end)

          expect(output_buffer.to_str).to have_tag("form li input##{@new_post.class.name.underscore}_title[@maxlength='#{maxlength}']")
        end

        it 'should have maxlength if the optional :if or :unless options are not supplied' do
          should_have_maxlength(42, :options => {:maximum => 42})
        end

        it 'should have default maxlength if the optional :if condition is not satisifed' do
          should_have_maxlength(default_maxlength, :options => {:maximum => 42, :if => false})
        end

        it 'should have default_maxlength if the optional :if proc evaluates to false' do
          should_have_maxlength(default_maxlength, :options => {:maximum => 42, :if => proc { |record| false }})
        end

        it 'should have maxlength if the optional :if proc evaluates to true' do
          should_have_maxlength(42, :options => { :maximum => 42, :if => proc { |record| true } })
        end

        it 'should have default maxlength if the optional :if with a method name evaluates to false' do
          expect(@new_post).to receive(:specify_maxlength).at_least(1).and_return(false)
          should_have_maxlength(default_maxlength, :options => { :maximum => 42, :if => :specify_maxlength })
        end

        it 'should have maxlength if the optional :if with a method name evaluates to true' do
          expect(@new_post).to receive(:specify_maxlength).at_least(1).and_return(true)
          should_have_maxlength(42, :options => { :maximum => 42, :if => :specify_maxlength })
        end

        it 'should have default maxlength if the optional :unless proc evaluates to true' do
          should_have_maxlength(default_maxlength, :options => { :maximum => 42, :unless => proc { |record| true } })
        end

        it 'should have maxlength if the optional :unless proc evaluates to false' do
          should_have_maxlength(42, :options => { :maximum => 42, :unless => proc { |record| false } })
        end

        it 'should have default maxlength if the optional :unless with a method name evaluates to true' do
          expect(@new_post).to receive(:specify_maxlength).at_least(1).and_return(true)
          should_have_maxlength(default_maxlength, :options => { :maximum => 42, :unless => :specify_maxlength })
        end

        it 'should have maxlength if the optional :unless with a method name evaluates to false' do
          expect(@new_post).to receive(:specify_maxlength).at_least(1).and_return(false)
          should_have_maxlength(42, :options => { :maximum => 42, :unless => :specify_maxlength })
        end
      end

      describe 'any conditional validation' do
        describe 'proc that calls an instance method' do
          it 'calls the method on the object' do
            expect(@new_post).to receive(:something?)
            expect(@new_post.class).to receive(:validators_on).with(:title).at_least(1).and_return([
              active_model_presence_validator([:title], { :unless => -> { something? } })
            ])
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title))
            end)
          end
        end

        describe 'proc with arity that calls an instance method' do
          it 'calls the method on the object' do
            expect(@new_post).to receive(:something?)
            expect(@new_post.class).to receive(:validators_on).with(:title).at_least(1).and_return([
              active_model_presence_validator([:title], { :unless => ->(user) { user.something? } })
            ])
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title))
            end)
          end
        end

        describe 'symbol method name' do
          it 'calls the method on the object if the method exists' do
            expect(@new_post).to receive(:something?)
            expect(@new_post.class).to receive(:validators_on).with(:title).at_least(1).and_return([
              active_model_presence_validator([:title], { :unless => :something? })
            ])
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title))
            end)
          end
        end

        describe 'any other conditional' do
          it 'does not raise an error' do
            @conditional = double()
            expect(@new_post.class).to receive(:validators_on).with(:title).at_least(1).and_return([
              active_model_presence_validator([:title], { :unless => @conditional })
            ])
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title))
            end)
          end
        end

      end

    end
  end

  describe "when namespace is provided" do

    before do
      concat(semantic_form_for(@new_post, :namespace => 'context2') do |builder|
        concat(builder.input(:title, :as => :string))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_post_title_input")
    it_should_have_label_and_input_with_id("context2_post_title")

  end

  describe "when index is provided" do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.fields_for(:author, :index => 3) do |author|
          concat(author.input(:name, :as => :string))
        end)
      end)
    end

    it 'should index the id of the wrapper' do
      expect(output_buffer.to_str).to have_tag("li#post_author_attributes_3_name_input")
    end

    it 'should index the id of the select tag' do
      expect(output_buffer.to_str).to have_tag("input#post_author_attributes_3_name")
    end

    it 'should index the name of the select tag' do
      expect(output_buffer.to_str).to have_tag("input[@name='post[author_attributes][3][name]']")
    end

  end


  describe "when no object is provided" do
    before do
      concat(semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:title, :as => :string))
      end)
    end

    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("project_title")
    it_should_have_input_with_id("project_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("project[title]")
  end

  describe "when size is nil" do
    before do
      concat(semantic_form_for(:project, :url => 'http://test.host/') do |builder|
        concat(builder.input(:title, :as => :string, :input_html => {:size => nil}))
      end)
    end

    it "should have no size attribute" do
      expect(output_buffer.to_str).not_to have_tag("input[@size]")
    end
  end

  describe "when required" do

    context "and configured to use HTML5 attribute" do
      it "should add the required attribute to the input's html options" do
        with_config :use_required_attribute, true do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => :string, :required => true))
          end)
          expect(output_buffer.to_str).to have_tag("input[@required]")
        end
      end
    end

    context "and configured to not use HTML5 attribute" do
      it "should add the required attribute to the input's html options" do
        with_config :use_required_attribute, false do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :as => :string, :required => true))
          end)
          expect(output_buffer.to_str).not_to have_tag("input[@required]")
        end
      end
    end

  end

end

