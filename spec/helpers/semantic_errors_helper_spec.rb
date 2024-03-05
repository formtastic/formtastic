# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Formtastic::FormBuilder#semantic_errors' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
    @title_errors = ['must not be blank', 'must be awesome']
    @base_errors = ['base error message', 'nasty error']
    @base_error = 'one base error'
    @errors = double('errors')
    allow(@new_post).to receive(:errors).and_return(@errors)
  end

  describe 'when there is only one error on base' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
    end

    it 'should render an unordered list' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors).to have_tag('ul.errors li', :text => @base_error)
      end
    end
  end

  describe 'when there is more than one error on base' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_errors)
    end

    it 'should render an unordered list' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors).to have_tag('ul.errors')
        @base_errors.each do |error|
          expect(builder.semantic_errors).to have_tag('ul.errors li', :text => error)
        end
      end
    end
  end

  describe 'when there are errors on title' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:title)).and_return(@title_errors)
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return([])
    end

    it 'should render an unordered list' do
      semantic_form_for(@new_post) do |builder|
        title_name = builder.send(:localized_string, :title, :title, :label) || builder.send(:humanized_attribute_name, :title)
        expect(builder.semantic_errors(:title)).to have_tag('ul.errors li', :text => title_name << " " << @title_errors.to_sentence)
      end
    end
  end

  describe 'when there are errors on title and base' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:title)).and_return(@title_errors)
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
    end

    it 'should render an unordered list' do
      semantic_form_for(@new_post) do |builder|
        title_name = builder.send(:localized_string, :title, :title, :label) || builder.send(:humanized_attribute_name, :title)
        expect(builder.semantic_errors(:title)).to have_tag('ul.errors li', :text => title_name << " " << @title_errors.to_sentence)
        expect(builder.semantic_errors(:title)).to have_tag('ul.errors li', :text => @base_error)
      end
    end
  end

  describe 'when there are no errors' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:title)).and_return(nil)
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(nil)
    end

    it 'should return nil' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors(:title)).to be_nil
      end
    end
  end

  describe 'when there is one error on base and options with class is passed' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
    end

    it 'should render an unordered list with given class' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors(:class => "awesome")).to have_tag('ul.awesome li', :text => @base_error)
      end
    end
  end

  describe 'when :base is passed in as an argument' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
    end

    it 'should ignore :base and only render base errors once' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors(:base)).to have_tag('ul li', :count => 1)
        expect(builder.semantic_errors(:base)).not_to have_tag('ul li', :text => "Base #{@base_error}")
      end
    end
  end

end
