# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'ButtonAction', 'when submitting' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:submit, :as => :button))
    end)
  end

  it 'should render a submit type of button' do
    expect(output_buffer.to_str).to have_tag('li.action.button_action button[@type="submit"]')
  end

end

RSpec.describe 'ButtonAction', 'when resetting' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything

    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:reset, :as => :button))
    end)
  end

  it 'should render a reset type of button' do
    expect(output_buffer.to_str).to have_tag('li.action.button_action button[@type="reset"]', :text => "Reset Post")
  end

  it 'should not render a value attribute' do
    expect(output_buffer.to_str).not_to have_tag('li.action.button_action button[@value]')
  end

end

RSpec.describe 'InputAction', 'when cancelling' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  it 'should raise an error' do
    expect {
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.action(:cancel, :as => :button))
      end)
    }.to raise_error(Formtastic::UnsupportedMethodForAction)
  end

end