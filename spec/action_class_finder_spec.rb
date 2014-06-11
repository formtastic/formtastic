# encoding: utf-8
require 'spec_helper'
require 'formtastic/action_class_finder'

describe Formtastic::ActionClassFinder do
  include FormtasticSpecHelper

  it_behaves_like 'Specialized Class Finder' do
    let(:default) { Formtastic::Actions }
    let(:namespaces_setting) { :action_namespaces }
  end
end
