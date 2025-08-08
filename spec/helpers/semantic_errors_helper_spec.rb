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
    @base_error = ['one base error']
    @errors = double('errors')
    allow(@new_post).to receive(:errors).and_return(@errors)
  end

  describe 'when there is only one error on base' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
      allow(@errors).to receive(:attribute_names).and_return([:base])
    end

    it 'should render an unordered list' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors).to have_tag('ul.errors li', text: 'one base error')
      end
    end
  end

  describe 'when there is more than one error on base' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_errors)
      allow(@errors).to receive(:attribute_names).and_return([:base])
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
      allow(@errors).to receive(:attribute_names).and_return([:title])
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
      allow(@errors).to receive(:attribute_names).and_return([:title, :base])
    end

    it 'should render an unordered list' do
      semantic_form_for(@new_post) do |builder|
        title_name = builder.send(:localized_string, :title, :title, :label) || builder.send(:humanized_attribute_name, :title)
        expect(builder.semantic_errors(:title)).to have_tag('ul.errors li', :text => title_name << " " << @title_errors.to_sentence)
        expect(builder.semantic_errors(:title)).to have_tag('ul.errors li', text: 'one base error')
      end
    end
  end

  describe 'when there are no errors' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:title)).and_return([])
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return([])
      allow(@errors).to receive(:attribute_names).and_return([])
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
      allow(@errors).to receive(:attribute_names).and_return([])
    end

    it 'should render an unordered list with given class' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors(:class => "awesome")).to have_tag('ul.awesome li', text: 'one base error')
      end
    end
  end

  describe 'when :base is passed in as an argument' do
    before do
      allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
      allow(@errors).to receive(:attribute_names).and_return([:base])
    end

    it 'should ignore :base and only render base errors once' do
      semantic_form_for(@new_post) do |builder|
        expect(builder.semantic_errors(:base)).to have_tag('ul li', :count => 1)
        expect(builder.semantic_errors(:base)).not_to have_tag('ul li', :text => "Base #{@base_error}")
      end
    end
  end

  describe 'when no attribute args or base are passed' do
    before do
      @author = AuthorWithValidations.new(name: 'a', surname: 'b', login: 'asdf')
      @author.valid?
      @author.errors.add(:base, 'Base error')
    end

    it 'should render base and all errors when no args are passed' do
      semantic_form_for(@author) do |builder|
        without_args = builder.semantic_errors

        expect(without_args).to have_tag('li', text: /Name.*too short/, count: 1)
        expect(without_args).to have_tag('li', text: /Surname.*too short/, count: 1)
        expect(without_args).to have_tag('li', text: /Login.*too short/, count: 1)
        expect(without_args).to have_tag('li', text: /Base error/, count: 1)
      end
    end

    it 'should render base and all errors when no args are passed with custom HTML options' do
      semantic_form_for(@author) do |builder|
        with_opts = builder.semantic_errors(class: 'custom-errors', id: 'error-summary', data: { controller: 'awesome' })

        expect(with_opts).to have_tag('ul.custom-errors#error-summary[data-controller="awesome"]')
        expect(with_opts).to have_tag('li', text: /Name.*too short/, count: 1)
        expect(with_opts).to have_tag('li', text: /Surname.*too short/, count: 1)
        expect(with_opts).to have_tag('li', text: /Login.*too short/, count: 1)
        expect(with_opts).to have_tag('li', text: /Base error/, count: 1)
      end
    end
  end

  context 'when configure FormBuilder.semantic_errors_link_to_inputs is true' do
    before do
      Formtastic::FormBuilder.semantic_errors_link_to_inputs = true
    end

    after do
      Formtastic::FormBuilder.semantic_errors_link_to_inputs = false
    end


    describe 'when there is only one error on base' do
      before do
        allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
        allow(@errors).to receive(:attribute_names).and_return([])
      end

      it 'should render an unordered list' do
        semantic_form_for(@new_post) do |builder|
          expect(builder.semantic_errors).to have_tag('ul.errors li', text: 'one base error')
        end
      end
    end

    describe 'when there is more than one error on base' do
      before do
        allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_errors)
        allow(@errors).to receive(:attribute_names).and_return([:base])
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
        allow(@errors).to receive(:attribute_names).and_return([:base, :title])
      end

      it 'should render an unordered list' do
        semantic_form_for(@new_post) do |builder|
          title_name = builder.send(:localized_string, :title, :title, :label) || builder.send(:humanized_attribute_name, :title)
          expect(builder.semantic_errors(:title)).to have_tag('ul.errors li a', :text => title_name << " " << @title_errors.to_sentence)
        end
      end
    end

    describe 'when there are errors on title and base' do
      before do
        allow(@errors).to receive(:[]).with(errors_matcher(:title)).and_return(@title_errors)
        allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
        allow(@errors).to receive(:attribute_names).and_return([:base, :title])
      end

      it 'should render an unordered list where base has no link, and title error attribute links to title input field' do
        semantic_form_for(@new_post) do |builder|
          title_name = builder.send(:localized_string, :title, :title, :label) || builder.send(:humanized_attribute_name, :title)
          expect(builder.semantic_errors(:title)).to \
            have_tag('ul.errors li a',
              with: { href: "##{@new_post.model_name}_title" },
              text: title_name << " " << @title_errors.to_sentence
            )
          expect(builder.semantic_errors(:title)).to have_tag('ul.errors li', text: 'one base error')
        end
      end
    end

    describe 'when there are no errors' do
      before do
        allow(@errors).to receive(:[]).with(errors_matcher(:title)).and_return([])
        allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return([])
        allow(@errors).to receive(:attribute_names).and_return([])
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
        allow(@errors).to receive(:attribute_names).and_return([])
      end

      it 'should render an unordered list with given class' do
        semantic_form_for(@new_post) do |builder|
          expect(builder.semantic_errors(class: "awesome")).to have_tag('ul.awesome li', text: 'one base error')
        end
      end
    end

    describe 'when :base is passed in as an argument' do
      before do
        allow(@errors).to receive(:[]).with(errors_matcher(:base)).and_return(@base_error)
        allow(@errors).to receive(:attribute_names).and_return([])
      end

      it 'should ignore :base and only render base errors once' do
        semantic_form_for(@new_post) do |builder|
          expect(builder.semantic_errors(:base)).to have_tag('ul li', count: 1)
          expect(builder.semantic_errors(:base)).not_to have_tag('ul li', text: "Base #{@base_error}")
        end
      end
    end

    describe 'when no attribute args or base are passed' do
      before do
        @author = AuthorWithValidations.new(name: 'a', surname: 'b', login: 'asdf')
        @author.valid?
        @author.errors.add(:base, 'Base error')
      end

      it 'should render base and all errors when no args are passed' do
        semantic_form_for(@author) do |builder|
          without_args = builder.semantic_errors

          expect(without_args).to have_tag('ul.errors li a', text: /Name.*too short/, count: 1)
          expect(without_args).to have_tag('ul.errors li a', text: /Surname.*too short/, count: 1)
          expect(without_args).to have_tag('ul.errors li a', text: /Login.*too short/, count: 1)
          expect(without_args).to have_tag('ul.errors li', text: /Base error/, count: 1)
        end
      end

      it 'should render base and all errors when no args are passed with custom HTML options' do
        semantic_form_for(@author) do |builder|
          with_opts = builder.semantic_errors(class: 'custom-errors', id: 'error-summary', data: { role: 'alert' })

          expect(with_opts).to have_tag('ul.custom-errors#error-summary[data-role="alert"]')
          expect(with_opts).to have_tag('ul.custom-errors li a', text: /Name.*too short/, count: 1)
          expect(with_opts).to have_tag('ul.custom-errors li a', text: /Surname.*too short/, count: 1)
          expect(with_opts).to have_tag('ul.custom-errors li a', text: /Login.*too short/, count: 1)
          expect(with_opts).to have_tag('ul.custom-errors li', text: /Base error/, count: 1)
        end
      end
    end
  end # context 'when semantic_errors_link_to_inputs is true'
end
