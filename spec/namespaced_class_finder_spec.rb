# encoding: utf-8
require 'spec_helper'
require 'formtastic/namespaced_class_finder'

describe Formtastic::NamespacedClassFinder do
  include FormtasticSpecHelper

  let(:builder) { Formtastic::FormBuilder.allocate }
  subject(:finder) { Formtastic::NamespacedClassFinder.new(builder) }


  shared_examples 'Namespaced Class Finder' do
    let(:as) { :custom_class }
    let(:class_name ) { 'CustomClass'}
    let(:fake_class) { double('FakeClass') }


    subject(:found_class) { finder.find(as) }

    let(:namespaces) { [ Object, ] }

    context 'when first namespace is defined' do
      before do
        stub_const(class_name, fake_class)
      end

      it do
        expect(found_class).to be(fake_class)
      end
    end

    context 'when second namespace is defined' do
      before do
        stub_const('Formtastic::FormBuilder::' + class_name, fake_class)
      end

      it do
        expect(found_class).to be(fake_class)
      end
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
