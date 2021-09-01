# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'
require 'formtastic/input_class_finder'

RSpec.describe Formtastic::InputClassFinder do
  it_behaves_like 'Specialized Class Finder' do
    let(:default) { Formtastic::Inputs }
    let(:namespaces_setting) { :input_namespaces }
  end
end
