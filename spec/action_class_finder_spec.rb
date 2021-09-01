# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'
require 'formtastic/action_class_finder'

RSpec.describe Formtastic::ActionClassFinder do
  include FormtasticSpecHelper

  it_behaves_like 'Specialized Class Finder' do
    let(:default) { Formtastic::Actions }
    let(:namespaces_setting) { :action_namespaces }
  end
end
