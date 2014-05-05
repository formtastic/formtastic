# encoding: utf-8
require 'spec_helper'
require 'formtastic/action_class_finder'

describe Formtastic::ActionClassFinder do
  include FormtasticSpecHelper

  let(:builder) { Formtastic::FormBuilder.allocate }
  subject(:finder) { Formtastic::ActionClassFinder.new(builder) }

  it 'has correct namespaces' do
    expect(finder.namespaces).to eq([Object,Formtastic::FormBuilder, Formtastic::Actions])
  end
end
