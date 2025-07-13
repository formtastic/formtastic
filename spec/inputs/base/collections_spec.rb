# frozen_string_literal: true
require 'fast_spec_helper'
require 'inputs/base/collections'

class MyInput
  include Formtastic::Inputs::Base::Collections
end

RSpec.describe MyInput do
  let(:builder) { double }
  let(:template) { double }
  let(:model_class) { double }
  let(:model) { double(:class => model_class) }
  let(:model_name) { "post" }
  let(:method) { double }
  let(:options) { Hash.new }
  
  let(:instance) { MyInput.new(builder, template, model, model_name, method, options) }

  # class Whatever < ActiveRecord::Base
  #   enum :status => [:active, :archived]
  # end
  #
  # Whatever.statuses
  #
  # Whatever.new.status
  #
  # f.input :status
  describe "#collection_from_enum" do
    
    let(:method) { :status }

    context "when an enum is defined for the method" do
      before do
        statuses = ActiveSupport::HashWithIndifferentAccess.new("active"=>0, "inactive"=>1)
        allow(model_class).to receive(:statuses) { statuses }
        allow(model).to receive(:defined_enums) { {"status" => statuses } }
        allow(model).to receive(:model_name).and_return(double(i18n_key: model_name))
      end

      context 'no translations available' do
        it 'returns an Array of EnumOption objects based on the enum options hash' do
          expect(instance.collection_from_enum).to eq [["Active", "active"],["Inactive", "inactive"]]
        end
      end

      context 'with translations' do
        before do
          ::I18n.backend.store_translations :en, :activerecord => {
            :attributes => {
              :post => {
                :statuses => {
                  :active => "I am active",
                  :inactive => "I am inactive"
                }
              }
            }
          }
        end
        it 'returns an Array of EnumOption objects based on the enum options hash' do
          expect(instance.collection_from_enum).to eq [["I am active", "active"],["I am inactive", "inactive"]]
        end

        after do
          ::I18n.backend.store_translations :en, {}
        end
      end
    end

    context "when an enum is not defined" do
      it 'returns nil' do
        expect(instance.collection_from_enum).to eq nil
      end
    end
  end

  describe '#collection' do
    context 'when the raw collection is a string' do
      it 'returns the string' do
        allow(instance).to receive(:raw_collection).and_return("one_status_only")
        expect(instance.collection).to eq "one_status_only"
      end
    end

    context 'when the raw collection is an array of strings' do
      it 'returns the array of symbols' do
        allow(instance).to receive(:raw_collection).and_return(["active", "inactive", "pending"])
        expect(instance.collection).to be_an(Array)
        expect(instance.collection).to eq ["active", "inactive", "pending"]
      end
    end

    context 'when the raw collection is an array of arrays' do
      it 'returns the array of arrays' do
        allow(instance).to receive(:raw_collection).and_return([["inactive", "0"], ["active", "1"], ["pending", "2"]])
        expect(instance.collection).to be_an(Array)
        expect(instance.collection).to eq [["inactive", "0"], ["active", "1"], ["pending", "2"]]
      end
    end

    context 'when the raw collection is an array of symbols' do
      it 'returns the array of symbols' do
        allow(instance).to receive(:raw_collection).and_return([:active, :inactive, :pending])
        expect(instance.collection).to be_an(Array)
        expect(instance.collection).to eq [:active, :inactive, :pending]
      end
    end

    context 'when the raw collection is a hash' do
      it 'will be mapped into array form' do
        allow(instance).to receive(:raw_collection).and_return({ inactive: 0, active: 1, pending: 2 })
        expect(instance.collection).to be_an(Array)
        expect(instance.collection).to eq [[:inactive, 0], [:active, 1], [:pending, 2]]
      end
    end
  end

end

