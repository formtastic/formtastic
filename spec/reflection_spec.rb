# encoding: utf-8
require 'spec_helper'

RSpec.describe 'Formtastic::Reflection' do

  include FormtasticSpecHelper

  before do
    mock_everything
  end

  class ReflectionTester
    def initialize(model_object)
      @object = model_object
    end

    def macro
      :belongs_to
    end

    def options
      { foreign_key: 'reviewer_id' }
    end
  end

  module Mongoid
    class BelongsTo
      def initialize(model_object)
        @object = model_object
      end

      def options
        { foreign_key: 'reviewer_id' }
      end
    end
  end

  let(:regular_reflection) { ReflectionTester.new(@new_post) }
  let(:mongoid7_reflection) { Mongoid::BelongsTo.new(@new_post) }
  let(:mongoid_reflection) do
    ::MongoidReflectionMock.new('reflection',
        :options => Proc.new { raise NoMethodError, "Mongoid has no reflection.options" },
        :klass => ::Author, :macro => :referenced_in, :foreign_key => "reviewer_id")
  end

  describe '#macro' do
    context 'reflection as regular object' do
      it 'returns :belongs_to from macro method' do 
        expect(Formtastic::Reflection.new(regular_reflection).macro).to eq(:belongs_to)
      end
    end

    context 'reflection as mongoid < 7.0 object' do
      it 'returns :referenced_in from macro method' do
        expect(Formtastic::Reflection.new(mongoid_reflection).macro).to eq(:referenced_in)
      end
    end

    context 'reflection as mongoid >= 7.0 object' do
      it 'returns :belongs_to from class name' do
        expect(Formtastic::Reflection.new(mongoid7_reflection).macro).to eq(:belongs_to)
      end
    end
  end

  describe '#primary_key' do
    let(:method) { :reviewers }

    context 'reflection as regular object' do
      it 'returns :reviewer_id' do
        expect(Formtastic::Reflection.new(regular_reflection).primary_key(method)).to eq(:reviewer_id)
      end
    end

    context 'reflection as mongoid < 7.0 object' do
      it 'returns :reviewer_id from foreign_key' do
        expect(Formtastic::Reflection.new(mongoid_reflection).primary_key(method)).to eq(:reviewer_id)
      end
    end

    context 'reflection as mongoid >= 7.0 object' do
      it 'returns :reviewer_id from options method' do
        expect(Formtastic::Reflection.new(mongoid7_reflection).primary_key(method)).to eq(:reviewer_id)
      end
    end
  end

  describe '#options' do
    context 'reflection as regular object' do
      it 'returns options with foreign key' do
        expect(Formtastic::Reflection.new(regular_reflection).options).to eq({ foreign_key: 'reviewer_id' })
      end
    end

    context 'reflection as mongoid < 7.0 object' do
      it 'returns empty hash' do
        expect(Formtastic::Reflection.new(mongoid_reflection).options).to eq({})
      end
    end

    context 'reflection as mongoid >= 7.0 object' do
      it 'returns options with foreign key' do
        expect(Formtastic::Reflection.new(mongoid7_reflection).options).to eq({ foreign_key: 'reviewer_id' })
      end
    end
  end
end
