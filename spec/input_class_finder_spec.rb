# encoding: utf-8
require 'spec_helper'
require 'formtastic/input_class_finder'

describe Formtastic::InputClassFinder do
  it_behaves_like 'Specialized Class Finder' do
    let(:default) { Formtastic::Inputs }
    let(:namespaces_setting) { :input_namespaces }
  end
end
