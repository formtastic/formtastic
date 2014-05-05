# encoding: utf-8
require 'spec_helper'
require 'formtastic/input_class_finder'

describe Formtastic::InputClassFinder do
  include FormtasticSpecHelper

  let(:builder) { Formtastic::FormBuilder.allocate }
  subject(:finder) { Formtastic::InputClassFinder.new(builder) }

  it 'has correct namespaces' do
    expect(finder.namespaces).to eq([Object,Formtastic::FormBuilder, Formtastic::Inputs])
  end
end
