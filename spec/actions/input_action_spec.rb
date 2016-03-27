# encoding: utf-8
require 'spec_helper'

RSpec.describe 'InputAction', 'when submitting' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
    
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:submit, :as => :input))
    end)
  end
  
  it 'should render a submit type of input' do
    expect(output_buffer).to have_tag('li.action.input_action input[@type="submit"]')
  end

end

RSpec.describe 'InputAction', 'when resetting' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.action(:reset, :as => :input))
    end)
  end
  
  it 'should render a reset type of input' do
    expect(output_buffer).to have_tag('li.action.input_action input[@type="reset"]')
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
        concat(builder.action(:cancel, :as => :input))
      end)
    }.to raise_error(Formtastic::UnsupportedMethodForAction)
  end
  
end