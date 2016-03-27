# encoding: utf-8
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
      allow(Rails.application.config).to receive(:cache_classes).and_return(cache_classes)
    end

    context 'when cache_classes is on' do
      let(:cache_classes) { true }
      it_behaves_like 'Namespaced Class Finder'
    end

    context 'when cache_classes is off' do
      let(:cache_classes) { false }
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
