# encoding: utf-8
require 'spec_helper'

describe 'SemanticFormBuilder#errors_on' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
    @title_errors = ['must not be blank', 'must be longer than 10 characters', 'must be awesome']
    @errors = mock('errors')
    @new_post.stub!(:errors).and_return(@errors)
  end

  describe 'when there are errors' do
    before do
      @errors.stub!(:[]).with(:title).and_return(@title_errors)
    end

    after do
      ::Formtastic::SemanticFormBuilder.default_inline_error_class = 'inline-errors'
      ::Formtastic::SemanticFormBuilder.default_error_list_class = 'errors'
    end

    it 'should render a paragraph with the errors joined into a sentence when inline_errors config is :sentence' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :sentence
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('p.inline-errors', @title_errors.to_sentence)
      end
    end

    it 'should render a paragraph with a overridden default class' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :sentence
      ::Formtastic::SemanticFormBuilder.default_inline_error_class = 'better-errors'
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('p.better-errors', @title_errors.to_sentence)
      end
    end

    it 'should render a paragraph with the errors joined into a sentence when inline_errors config is :sentence with a customized error class' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :sentence
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title, :error_class => 'better-errors').should have_tag('p.better-errors', @title_errors.to_sentence)
      end
    end

    it 'should render an unordered list with the class errors when inline_errors config is :list' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :list
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('ul.errors')
        @title_errors.each do |error|
          builder.errors_on(:title).should have_tag('ul.errors li', error)
        end
      end
    end

    it 'should render an unordered list with the class overridden default class' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :list
      ::Formtastic::SemanticFormBuilder.default_error_list_class = "better-errors"
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('ul.better-errors')
        @title_errors.each do |error|
          builder.errors_on(:title).should have_tag('ul.better-errors li', error)
        end
      end
    end

    it 'should render an unordered list with the class errors when inline_errors config is :list with a customized error class' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :list
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title, :error_class => 'better-errors').should have_tag('ul.better-errors')
        @title_errors.each do |error|
          builder.errors_on(:title, :error_class => 'better-errors').should have_tag('ul.better-errors li', error)
        end
      end
    end

    it 'should render a paragraph with the first error when inline_errors config is :first' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :first
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should have_tag('p.inline-errors', @title_errors.first)
      end
    end

    it 'should render a paragraph with the first error when inline_errors config is :first with a customized error class' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :first
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title, :error_class => 'better-errors').should have_tag('p.better-errors', @title_errors.first)
      end
    end

    it 'should return nil when inline_errors config is :none' do
      ::Formtastic::SemanticFormBuilder.inline_errors = :none
      semantic_form_for(@new_post) do |builder|
        builder.errors_on(:title).should be_nil
      end
    end

  end

  describe 'when there are no errors (nil)' do
    before do
      @errors.stub!(:[]).with(:title).and_return(nil)
    end

    it 'should return nil when inline_errors config is :sentence, :list or :none' do
      [:sentence, :list, :none].each do |config|
        with_config :inline_errors, config do
          semantic_form_for(@new_post) do |builder|
            builder.errors_on(:title).should be_nil
          end
        end
      end
    end
  end

  describe 'when there are no errors (empty array)' do
    before do
      @errors.stub!(:[]).with(:title).and_return([])
    end

    it 'should return nil when inline_errors config is :sentence, :list or :none' do
      [:sentence, :list, :none].each do |config|
        ::Formtastic::SemanticFormBuilder.inline_errors = config
        semantic_form_for(@new_post) do |builder|
          builder.errors_on(:title).should be_nil
        end
      end
    end
  end

  describe 'when file type columns have errors' do
    it "should list errors added on metadata fields" do
      @errors.stub!(:[]).with(:document_file_name).and_return(['must be provided'])
      @errors.stub!(:[]).with(:document_file_size).and_return(['must be less than 4mb'])
      @errors.stub!(:[]).with(:document_content_type).and_return(['must be an image'])
      @errors.stub!(:[]).with(:document).and_return(nil)

      with_config :inline_errors, :sentence do
        @form = semantic_form_for(@new_post) do |builder|
          concat(builder.input(:document))
        end
      end 
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("li[@class='file optional error']")
      output_buffer.should have_tag('p.inline-errors', (['must be an image','must be provided', 'must be less than 4mb']).to_sentence)
    end
  end

  describe 'when there are errors on the association and column' do

    it "should list all unique errors" do
      ::Post.stub!(:reflections).and_return({:author => mock('reflection', :options => {}, :macro => :belongs_to)})

      @errors.stub!(:[]).with(:author).and_return(['must not be blank'])
      @errors.stub!(:[]).with(:author_id).and_return(['is already taken', 'must not be blank']) # note the duplicate of association

      with_config :inline_errors, :list do
        @form = semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author))
        end
      end
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("ul.errors li", /must not be blank/, :count => 1)
      output_buffer.should have_tag("ul.errors li", /is already taken/, :count => 1)
    end

  end

end

