# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe 'LayoutHelper' do
  
  include FormtasticSpecHelper
  include Formtastic::LayoutHelper
  
  before do
    @output_buffer = ''
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
end

