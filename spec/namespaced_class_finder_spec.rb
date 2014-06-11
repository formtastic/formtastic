# encoding: utf-8
require 'spec_helper'
require 'formtastic/namespaced_class_finder'

describe Formtastic::NamespacedClassFinder do
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

      it { expect(found_class).to be(CustomClass) }
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

  context '#finder_method' do
    subject { finder.finder_method }

    before do
      Rails.application.config.stub(:cache_classes).and_return(cache_classes)
    end

    context 'when cache_classes is on' do
      let(:cache_classes) { true }
      it_behaves_like 'Namespaced Class Finder'

      it { should eq(:find_with_const_defined) }
    end

    context 'when cache_classes is off' do
      let(:cache_classes) { false }
      it_behaves_like 'Namespaced Class Finder'

      it { should eq(:find_by_trying) }
    end
  end

  context '#[]' do
    it 'caches calls' do
      expect(subject).to receive(:find).once.and_call_original
      subject[:object]
      subject[:object]
    end
  end


  context '#find_with_const_defined' do
    subject(:finder) { Formtastic::NamespacedClassFinder.new([])}
  end
end
