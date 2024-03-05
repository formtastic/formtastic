# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'file input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:body, :as => :file))
    end)
  end

  it_should_have_input_wrapper_with_class("file")
  it_should_have_input_wrapper_with_class(:input)
  it_should_have_input_wrapper_with_id("post_body_input")
  it_should_have_label_with_text(/Body/)
  it_should_have_label_for("post_body")
  it_should_have_input_with_id("post_body")
  it_should_have_input_with_name("post[body]")
  it_should_apply_error_logic_for_input_type(:file)

  it 'should use input_html to style inputs' do
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:title, :as => :file, :input_html => { :class => 'myclass' }))
    end)
    expect(output_buffer.to_str).to have_tag("form li input.myclass")
  end

  describe "when namespace is provided" do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@new_post, :namespace => 'context2') do |builder|
        concat(builder.input(:body, :as => :file))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_post_body_input")
    it_should_have_label_and_input_with_id("context2_post_body")

  end

  describe "when index is provided" do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.fields_for(:author, :index => 3) do |author|
          concat(author.input(:name, :as => :file))
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


  context "when required" do
    it "should add the required attribute to the input's html options" do
      with_config :use_required_attribute, true do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :file, :required => true))
        end)
        expect(output_buffer.to_str).to have_tag("input[@required]")
      end
    end
  end

end

