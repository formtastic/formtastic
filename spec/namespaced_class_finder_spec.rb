# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'
require 'formtastic/namespaced_class_finder'

RSpec.describe Formtastic::NamespacedClassFinder do
  include FormtasticSpecHelper

  before do
    stub_const('SearchPath', Module.new)
  end

  let(:search_path) { [ SearchPath ] }
  subject(:finder) { Formtastic::NamespacedClassFinder.new(search_path) }

  shared_examples 'Namespaced Class Finder' do
    subject(:found_class) { finder.find(:custom_class) }

    context 'Input defined in the Object scope' do
      before do
        stub_const('CustomClass', Class.new)
      end

      it { expect(found_class).to be(CustomClass) }
    end

    context 'Input defined in the search path' do
      before do
        stub_const('SearchPath::CustomClass', Class.new)
      end

      it { expect(found_class).to be(SearchPath::CustomClass) }
    end

    context 'Input defined both in the Object scope and the search path' do
      before do
        stub_const('CustomClass', Class.new)
        stub_const('SearchPath::CustomClass', Class.new)
      end

      it { expect(found_class).to be(SearchPath::CustomClass) }
    end

    context 'Input defined outside the search path' do
      before do
        stub_const('Foo', Module.new)
        stub_const('Foo::CustomClass', Class.new)
      end

      let(:error) { Formtastic::NamespacedClassFinder::NotFoundError }

      it { expect { found_class }.to raise_error(error) }
    end
  end

  context '#finder' do
    before do
      allow(Rails.application.config).to receive(:eager_load).and_return(eager_load)
    end

    context 'when eager_load is on' do
      let(:eager_load) { true }

      it "finder_method is :find_with_const_defined" do
        expect(described_class.finder_method).to eq(:find_with_const_defined)
      end

      it_behaves_like 'Namespaced Class Finder'
    end

    context 'when eager_load is off' do
      let(:eager_load) { false }

      it "finder_method is :find_by_trying" do
        described_class.instance_variable_set(:@finder_method, nil) # clear cache
        expect(described_class.finder_method).to eq(:find_by_trying)
      end

      it_behaves_like 'Namespaced Class Finder'
    end
  end

  context '#find' do
    it 'caches calls' do
      expect(subject).to receive(:resolve).once.and_call_original
      subject.find(:object)
      subject.find(:object)
    end
  end

end
