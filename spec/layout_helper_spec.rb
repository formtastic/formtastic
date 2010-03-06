# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe 'LayoutHelper' do
  
  include FormtasticSpecHelper
  include Formtastic::LayoutHelper
  
  before do
    @output_buffer = ActiveSupport::SafeBuffer.new
  end
  
  describe '#formtastic_stylesheet_link_tag' do
    
    before do
      concat(formtastic_stylesheet_link_tag())
    end
    
    it 'should render a link to formtastic.css' do
      output_buffer.should have_tag("link[@href='/stylesheets/formtastic.css']")
    end
    
    it 'should render a link to formtastic_changes.css' do
      output_buffer.should have_tag("link[@href='/stylesheets/formtastic_changes.css']")
    end
    
  end

  # FIXME: Rspec issue?
  def controller
    mock('controller')
  end

  # FIXME: Rspec issue?
  def config
    returning mock('config') do |config|
      config.stub!(:assets_dir).and_return('')
    end
  end

end

