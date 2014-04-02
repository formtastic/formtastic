# encoding: utf-8
require 'spec_helper'
require 'formtastic/class_finder'

describe 'Formtastic::ClassFinder#find_class' do

  include FormtasticSpecHelper

  shared_examples "Class Finder" do
    before do
      Rails.application.config.stub(:cache_classes).and_return(cache_classes)
    end

    subject(:finder) { Formtastic::ClassFinder.find_class(as, suffix, namespaces) }

    let(:class_name) { "#{as.to_s.camelize}#{suffix}" }
    let(:top_level_class) { class_name }
    let(:namespaced_class) { "#{builder.class}::#{class_name}" }
    let(:formtastic_class) { "Formtastic::#{suffix.pluralize}::#{class_name}" }

    context 'when a class does not exist' do
      let(:as) { :unknown }

      it 'should raise an error' do
        expect{ subject }.to raise_error(Formtastic::ClassFinder::NotFoundError)
      end
    end

    context 'when searched class exists' do
      let(:as) { :custom_thing }

      describe 'in first namespace' do
        before do
          stub_const(top_level_class, double('first'))
          stub_const(namespaced_class, double('second'))
          stub_const(formtastic_class, double('third'))
        end

        it { should be top_level_class.constantize }
      end

      describe 'in second namespace' do
        before do
          stub_const(namespaced_class, double('second'))
          stub_const(formtastic_class, double('third'))
        end

        it { should be namespaced_class.constantize }
      end

      describe 'in thid namespace' do
        before do
          stub_const(formtastic_class, double('third'))
        end

        it { should be formtastic_class.constantize }
      end
    end

    describe 'class defined in superclass' do
      let(:builder_subclass) { stub_const('CustomFormBuilder', Class.new(Formtastic::FormBuilder)) }
      let(:builder) { double('builder', :class => builder_subclass).extend(helper) }
      let(:as) { :string }

      let(:custom_class) { double('inherited') }

      before do
        stub_const("Formtastic::FormBuilder::#{class_name}", custom_class)
        stub_const(formtastic_class, double('default class'))
      end

      it { should be custom_class }
    end

  end

  shared_examples 'Class Finder for Helper' do
    let(:module_name) { name.to_s.camelize }
    it_behaves_like "Class Finder" do
      let(:helper) { "Formtastic::Helpers::#{module_name}Helper".constantize }
      let(:suffix) { module_name }
      let(:builder) { double(:class => Formtastic::FormBuilder).extend(helper) }
      let(:namespaces) { builder.send("#{module_name.downcase}_class_namespaces") }
    end
  end

  shared_examples "Class Finder for Action Helper" do
    it_should_behave_like 'Class Finder for Helper' do
      let(:name) { 'Action' }
    end
  end

  shared_examples "Class Finder for Input Helper" do
    it_should_behave_like 'Class Finder for Helper' do
      let(:name) { 'Input' }
    end
  end

  context 'when Rails cache classes is on' do
    let(:cache_classes) { true }

    it_should_behave_like 'Class Finder for Input Helper'
    it_should_behave_like 'Class Finder for Action Helper'
  end

  context 'when Rails cache classes is off' do
    let(:cache_classes) { false }

    it_should_behave_like 'Class Finder for Input Helper'
    it_should_behave_like 'Class Finder for Action Helper'
  end

end
