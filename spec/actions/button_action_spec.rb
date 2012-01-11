# encoding: utf-8
require 'spec_helper'

describe 'ButtonAction', 'when submitting' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
    
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:submit, :as => :button))
    end)
  end
  
  it 'should render a submit type of input' do
    output_buffer.should have_tag('li.action.button_action button[@type="submit"]')
  end

end

describe 'ButtonAction', 'when resetting' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:reset, :as => :button))
    end)
  end
  
  it 'should render a reset type of input' do
    output_buffer.should have_tag('li.action.button_action button[@type="reset"]')
  end
  
end

describe 'InputAction', 'when cancelling' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end
  
  it 'should raise an error' do
    lambda { 
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.action(:cancel, :as => :button))
      end)
    }.should raise_error(Formtastic::UnsupportedMethodForAction)
  end
  
end