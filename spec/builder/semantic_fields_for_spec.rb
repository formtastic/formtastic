# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Formtastic::FormBuilder#fields_for' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
    allow(@new_post).to receive(:author).and_return(::Author.new)
  end

  context 'outside a form_for block' do
    it 'yields an instance of FormHelper.builder' do
      semantic_fields_for(@new_post) do |nested_builder|
        expect(nested_builder.class).to eq(Formtastic::Helpers::FormHelper.builder)
      end
      semantic_fields_for(@new_post.author) do |nested_builder|
        expect(nested_builder.class).to eq(Formtastic::Helpers::FormHelper.builder)
      end
      semantic_fields_for(:author, @new_post.author) do |nested_builder|
        expect(nested_builder.class).to eq(Formtastic::Helpers::FormHelper.builder)
      end
      semantic_fields_for(:author, @hash_backed_author) do |nested_builder|
        expect(nested_builder.class).to eq(Formtastic::Helpers::FormHelper.builder)
      end
    end

    it 'should respond to input' do
      semantic_fields_for(@new_post) do |nested_builder|
        expect(nested_builder.respond_to?(:input)).to be_truthy
      end
      semantic_fields_for(@new_post.author) do |nested_builder|
        expect(nested_builder.respond_to?(:input)).to be_truthy
      end
      semantic_fields_for(:author, @new_post.author) do |nested_builder|
        expect(nested_builder.respond_to?(:input)).to be_truthy
      end
      semantic_fields_for(:author, @hash_backed_author) do |nested_builder|
        expect(nested_builder.respond_to?(:input)).to be_truthy
      end
    end
  end

  context 'within a form_for block' do
    it 'yields an instance of FormHelper.builder' do
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(:author) do |nested_builder|
          expect(nested_builder.class).to eq(Formtastic::Helpers::FormHelper.builder)
        end
      end
    end

    it 'yields an instance of FormHelper.builder with hash-like model' do
      semantic_form_for(:user) do |builder|
        builder.semantic_fields_for(:author, @hash_backed_author) do |nested_builder|
          expect(nested_builder.class).to eq(Formtastic::Helpers::FormHelper.builder)
        end
      end
    end

    it 'nests the object name' do
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(@bob) do |nested_builder|
          expect(nested_builder.object_name).to eq('post[author]')
        end
      end
    end

    it 'supports passing collection as second parameter' do
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(:author, [@fred,@bob]) do |nested_builder|
          expect(nested_builder.object_name).to match(/post\[author_attributes\]\[\d+\]/)
        end
      end
    end

    it 'should sanitize html id for li tag' do
      allow(@bob).to receive(:column_for_attribute).and_return(double('column', :type => :string, :limit => 255))
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.semantic_fields_for(@bob, :index => 1) do |nested_builder|
          concat(nested_builder.inputs(:login))
        end)
      end)
      expect(output_buffer.to_str).to have_tag('form fieldset.inputs #post_author_1_login_input')
      # Not valid selector, so using good ol' regex
      expect(output_buffer.to_str).not_to match(/id="post\[author\]_1_login_input"/)
      # <=> output_buffer.should_not have_tag('form fieldset.inputs #post[author]_1_login_input')
    end

    it 'should use namespace provided in nested fields' do
      allow(@bob).to receive(:column_for_attribute).and_return(double('column', :type => :string, :limit => 255))
      concat(semantic_form_for(@new_post, :namespace => 'context2') do |builder|
        concat(builder.semantic_fields_for(@bob, :index => 1) do |nested_builder|
          concat(nested_builder.inputs(:login))
        end)
      end)
      expect(output_buffer.to_str).to have_tag('form fieldset.inputs #context2_post_author_1_login_input')
    end

    it 'should render errors on the nested inputs' do
      @errors = double('errors')
      allow(@errors).to receive(:[]).with(errors_matcher(:login)).and_return(['oh noes'])
      allow(@bob).to receive(:errors).and_return(@errors)

      concat(semantic_form_for(@new_post, :namespace => 'context2') do |builder|
        concat(builder.semantic_fields_for(@bob) do |nested_builder|
          concat(nested_builder.inputs(:login))
        end)
      end)
      expect(output_buffer.to_str).to match(/oh noes/)
    end

  end

  context "when I rendered my own hidden id input" do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''

      expect(@fred.posts.size).to eq(1)
      allow(@fred.posts.first).to receive(:persisted?).and_return(true)
      allow(@fred).to receive(:posts_attributes=)
      concat(semantic_form_for(@fred) do |builder|
        concat(builder.semantic_fields_for(:posts) do |nested_builder|
          concat(nested_builder.input(:id, :as => :hidden))
          concat(nested_builder.input(:title))
        end)
      end)
    end

    it "should only render one hidden input (my one)" do
      expect(output_buffer.to_str).to have_tag 'input#author_posts_attributes_0_id', :count => 1
    end

    it "should render the hidden input inside an li.hidden" do
      expect(output_buffer.to_str).to have_tag 'li.hidden input#author_posts_attributes_0_id'
    end
  end

end
