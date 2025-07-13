# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Formtastic::FormBuilder#actions' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  describe 'with a block' do
    describe 'when no options are provided' do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.actions do
            concat('hello')
          end)
        end)
      end

      it 'should render a fieldset inside the form, with a class of "actions"' do
        expect(output_buffer.to_str).to have_tag("form fieldset.actions")
      end

      it 'should render an ol inside the fieldset' do
        expect(output_buffer.to_str).to have_tag("form fieldset.actions ol")
      end

      it 'should render the contents of the block inside the ol' do
        expect(output_buffer.to_str).to have_tag("form fieldset.actions ol", :text => /hello/)
      end

      it 'should not render a legend inside the fieldset' do
        expect(output_buffer.to_str).not_to have_tag("form fieldset.actions legend")
      end
    end

    describe 'when a :name option is provided' do
      before do
        @legend_text = "Advanced options"

        concat(semantic_form_for(@new_post) do |builder|
          builder.actions :name => @legend_text do
          end
        end)
      end
      it 'should render a fieldset inside the form' do
        expect(output_buffer.to_str).to have_tag("form fieldset.actions legend", :text => /#{@legend_text}/)
      end
    end

    describe 'when other options are provided' do
      before do
        @id_option = 'advanced'
        @class_option = 'wide'

        concat(semantic_form_for(@new_post) do |builder|
          builder.actions :id => @id_option, :class => @class_option do
          end
        end)
      end
      it 'should pass the options into the fieldset tag as attributes' do
        expect(output_buffer.to_str).to have_tag("form fieldset##{@id_option}")
        expect(output_buffer.to_str).to have_tag("form fieldset.#{@class_option}")
      end
    end

  end

  describe 'without a block' do

    describe 'with no args (default buttons)' do

      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.actions)
        end)
      end

      it 'should render a form' do
        expect(output_buffer.to_str).to have_tag('form')
      end

      it 'should render an actions fieldset inside the form' do
        expect(output_buffer.to_str).to have_tag('form fieldset.actions')
      end

      it 'should not render a legend in the fieldset' do
        expect(output_buffer.to_str).not_to have_tag('form fieldset.actions legend')
      end

      it 'should render an ol in the fieldset' do
        expect(output_buffer.to_str).to have_tag('form fieldset.actions ol')
      end

      it 'should render a list item in the ol for each default action' do
        expect(output_buffer.to_str).to have_tag('form fieldset.actions ol li.action.input_action', :count => 1)
      end

    end

    describe 'with button names as args' do

      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.actions(:submit, :cancel, :reset))
        end)
      end

      it 'should render a form with a fieldset containing a list item for each button arg' do
        expect(output_buffer.to_str).to have_tag('form > fieldset.actions > ol > li.action', :count => 3)
      end

    end

    describe 'with button names as args and an options hash' do

     before do
       concat(semantic_form_for(@new_post) do |builder|
         concat(builder.actions(:submit, :cancel, :reset, :name => "Now click a button", :id => "my-id"))
       end)
     end

     it 'should render a form with a fieldset containing a list item for each button arg' do
       expect(output_buffer.to_str).to have_tag('form > fieldset.actions > ol > li.action', :count => 3)
     end

     it 'should pass the options down to the fieldset' do
       expect(output_buffer.to_str).to have_tag('form > fieldset#my-id.actions')
     end

     it 'should use the special :name option as a text for the legend tag' do
       expect(output_buffer.to_str).to have_tag('form > fieldset#my-id.actions > legend', :text => /Now click a button/)
     end

    end

  end

end

