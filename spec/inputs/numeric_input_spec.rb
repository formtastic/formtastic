# encoding: utf-8
require 'spec_helper'

describe 'numeric input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  it "should call NumberInput.new" do
    input = mock('input', :to_html => "HTML codez")
    ::Formtastic::Inputs::NumericInput.should_receive(:new).and_return(input)
    concat(semantic_form_for(@new_post) do |builder|
      concat(builder.input(:title, :as => :numeric))
    end)
  end
  
  it "should have an li.numeric" do
    with_deprecation_silenced do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :numeric))
      end)
    end
    output_buffer.should have_tag('li.numeric')
    output_buffer.should have_tag('li.input')
  end
  
  it "should warn that :numeric is deprecated in favor of :number" do
    ::ActiveSupport::Deprecation.should_receive(:warn)
    with_deprecation_silenced do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :numeric))
      end)
    end
  end

end

