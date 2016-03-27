# encoding: utf-8
require 'spec_helper'

RSpec.describe 'ButtonAction', 'when submitting' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
    
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:submit, :as => :button))
    end)
  end
  
  it 'should render a submit type of button' do
    expect(output_buffer).to have_tag('li.action.button_action button[@type="submit"]')
  end

end

RSpec.describe 'ButtonAction', 'when resetting' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:reset, :as => :button))
    end)
  end
  
  it 'should render a reset type of button' do
    expect(output_buffer).to have_tag('li.action.button_action button[@type="reset"]', :text => "Reset Post")
  end

  it 'should not render a value attribute' do
    expect(output_buffer).not_to have_tag('li.action.button_action button[@value]')
  end
  
end

RSpec.describe 'InputAction', 'when cancelling' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
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