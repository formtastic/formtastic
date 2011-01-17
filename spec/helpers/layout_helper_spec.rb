# encoding: utf-8
require 'spec_helper'

describe Formtastic::Helpers::LayoutHelper do

  include FormtasticSpecHelper
  include Formtastic::Helpers::LayoutHelper

  describe '#formtastic_stylesheet_link_tag' do

    it 'should render a link to formtastic.css' do
      formtastic_stylesheet_link_tag.should have_tag("link[@href='/stylesheets/formtastic.css']")
    end

    it 'should render a link to formtastic_changes.css' do
      formtastic_stylesheet_link_tag.should have_tag("link[@href='/stylesheets/formtastic_changes.css']")
    end

  end
end

