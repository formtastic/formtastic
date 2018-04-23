require 'fast_spec_helper'
require 'active_model'
require 'inputs/base/validations'

class MyInput
  attr_accessor :validations
  include Formtastic::Inputs::Base::Validations

  def validations?
    true
  end
end

RSpec.describe MyInput do
  let(:builder) { double }
  let(:template) { double }
  let(:model_class) { double }
  let(:model) { double(:class => model_class) }
  let(:model_name) { "post" }
  let(:method) { double }
  let(:options) { Hash.new }
  let(:validator) { double }
  let(:instance) do
    MyInput.new(builder, template, model, model_name, method, options).tap do |my_input|
      my_input.validations = validations
    end
  end

  describe '#required?' do
    context 'with a single validator' do
      let(:validations) { [validator] }

      context 'with options[:required] being true' do
        let(:options) { {required: true} }

        it 'is required' do
          expect(instance.required?).to be_truthy
        end
      end

      context 'with options[:required] being false' do
        let(:options) { {required: false} }

        it 'is not required' do
          expect(instance.required?).to be_falsey
        end
      end

      context 'with negated validation' do
        it 'is not required' do
          instance.not_required_through_negated_validation!
          expect(instance.required?).to be_falsey
        end
      end

      context 'with presence validator' do
        let (:validator) { double(options: {}, kind: :presence) }

        it 'is required' do
          expect(instance.required?).to be_truthy
        end

        context 'with options[:on] as symbol' do
          context 'with save context' do
            let (:validator) { double(options: {on: :save}, kind: :presence) }

            it 'is required' do
              expect(instance.required?).to be_truthy
            end
          end

          context 'with create context' do
            let (:validator) { double(options: {on: :create}, kind: :presence) }

            it 'is required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_truthy
            end

            it 'is not required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_falsey
            end
          end

          context 'with update context' do
            let (:validator) { double(options: {on: :update}, kind: :presence) }

            it 'is not required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_falsey
            end

            it 'is required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_truthy
            end
          end
        end

        context 'with options[:on] as array' do
          context 'with save context' do
            let (:validator) { double(options: {on: [:save]}, kind: :presence) }

            it 'is required' do
              expect(instance.required?).to be_truthy
            end
          end

          context 'with create context' do
            let (:validator) { double(options: {on: [:create]}, kind: :presence) }

            it 'is required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_truthy
            end

            it 'is not required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_falsey
            end
          end

          context 'with update context' do
            let (:validator) { double(options: {on: [:update]}, kind: :presence) }

            it 'is not required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_falsey
            end

            it 'is required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_truthy
            end
          end

          context 'with save and create context' do
            let (:validator) { double(options: {on: [:save, :create]}, kind: :presence) }

            it 'is required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_truthy
            end

            it 'is required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_truthy
            end
          end

          context 'with save and update context' do
            let (:validator) { double(options: {on: [:save, :create]}, kind: :presence) }

            it 'is required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_truthy
            end

            it 'is required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_truthy
            end
          end

          context 'with create and update context' do
            let (:validator) { double(options: {on: [:create, :update]}, kind: :presence) }

            it 'is required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_truthy
            end

            it 'is required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_truthy
            end
          end

          context 'with save and other context' do
            let (:validator) { double(options: {on: [:save, :foo]}, kind: :presence) }

            it 'is required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_truthy
            end

            it 'is required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_truthy
            end
          end

          context 'with create and other context' do
            let (:validator) { double(options: {on: [:create, :foo]}, kind: :presence) }

            it 'is required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_truthy
            end

            it 'is not required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_falsey
            end
          end

          context 'with update and other context' do
            let (:validator) { double(options: {on: [:update, :foo]}, kind: :presence) }

            it 'is not required for new records' do
              allow(model).to receive(:new_record?).and_return(true)
              expect(instance.required?).to be_falsey
            end

            it 'is required for existing records' do
              allow(model).to receive(:new_record?).and_return(false)
              expect(instance.required?).to be_truthy
            end
          end
        end
      end

      context 'with inclusion validator' do
        context 'with allow blank' do
          let (:validator) { double(options: {allow_blank: true}, kind: :inclusion) }

          it 'is not required' do
            expect(instance.required?).to be_falsey
          end
        end

        context 'without allow blank' do
          let (:validator) { double(options: {allow_blank: false}, kind: :inclusion) }

          it 'is required' do
            expect(instance.required?).to be_truthy
          end
        end
      end

      context 'with a length validator' do
        context 'with allow blank' do
          let (:validator) { double(options: {allow_blank: true}, kind: :length) }

          it 'is not required' do
            expect(instance.required?).to be_falsey
          end
        end

        context 'without allow blank' do
          let (:validator) { double(options: {allow_blank: false}, kind: :length) }

          it 'is not required' do
            expect(instance.required?).to be_falsey
          end

          context 'with a minimum > 0' do
            let (:validator) { double(options: {allow_blank: false, minimum: 1}, kind: :length) }

            it 'is required' do
              expect(instance.required?).to be_truthy
            end
          end

          context 'with a minimum <= 0' do
            let (:validator) { double(options: {allow_blank: false, minimum: 0}, kind: :length) }

            it 'is not required' do
              expect(instance.required?).to be_falsey
            end
          end

          context 'with a defined range starting with > 0' do
            let (:validator) { double(options: {allow_blank: false, within: 1..5}, kind: :length) }

            it 'is required' do
              expect(instance.required?).to be_truthy
            end
          end

          context 'with a defined range starting with <= 0' do
            let (:validator) { double(options: {allow_blank: false, within: 0..5}, kind: :length) }

            it 'is not required' do
              expect(instance.required?).to be_falsey
            end
          end
        end
      end

      context 'with another validator' do
        let (:validator) { double(options: {allow_blank: true}, kind: :foo) }

        it 'is not required' do
          expect(instance.required?).to be_falsey
        end
      end
    end

    context 'with multiple validators' do
      let(:validations) { [validator1, validator2] }

      context 'with a on create presence validator and a on update presence validator' do
        let(:validator1) { double(options: {on: :create}, kind: :presence) }
        let(:validator2) { double(options: {}, kind: :presence) }

        before :example do
          allow(model).to receive(:new_record?).and_return(false)
        end

        it 'is required' do
          expect(instance.required?).to be_truthy
        end
      end

      context 'with a on create presence validator and a presence validator' do
        let (:validator1) { double(options: {on: :create}, kind: :presence) }
        let (:validator2) { double(options: {}, kind: :presence) }

        before :example do
          allow(model).to receive(:new_record?).and_return(false)
        end

        it 'is required' do
          expect(instance.required?).to be_truthy
        end
      end

      context 'with a on create presence validator and a allow blank inclusion validator' do
        let(:validator1) { double(options: {on: :create}, kind: :presence) }
        let(:validator2) { double(options: {allow_blank: true}, kind: :inclusion) }

        before :example do
          allow(model).to receive(:new_record?).and_return(false)
        end

        it 'is required' do
          expect(instance.required?).to be_falsey
        end
      end
    end
  end

  describe '#validation_min' do
    let(:validations) { [validator] }

    context 'with a greater_than numericality validator' do
      let(:validator) { double(options: { greater_than: option_value }, kind: :numericality) }

      context 'with a symbol' do
        let(:option_value) { :a_symbol }

        it 'returns one greater' do
          allow(model).to receive(:send).with(option_value).and_return(14)
          expect(instance.validation_min).to eq 15
        end
      end

      context 'with a proc' do
        let(:option_value) { Proc.new { 10 } }

        it 'returns one greater' do
          expect(instance.validation_min).to eq 11
        end
      end

      context 'with a number' do
        let(:option_value) { 8 }

        it 'returns one greater' do
          expect(instance.validation_min).to eq 9
        end
      end
    end

    context 'with a greater_than_or_equal_to numericality validator' do
      let(:validator) do
        double(
          options: { greater_than_or_equal_to: option_value },
          kind: :numericality
        )
      end

      context 'with a symbol' do
        let(:option_value) { :a_symbol }

        it 'returns the instance method amount' do
          allow(model).to receive(:send).with(option_value).and_return(14)
          expect(instance.validation_min).to eq 14
        end
      end

      context 'with a proc' do
        let(:option_value) { Proc.new { 10 } }

        it 'returns the proc amount' do
          expect(instance.validation_min).to eq 10
        end
      end

      context 'with a number' do
        let(:option_value) { 8 }

        it 'returns the number' do
          expect(instance.validation_min).to eq 8
        end
      end
    end
  end

  describe '#validation_max' do
    let(:validations) do
      [
        ActiveModel::Validations::NumericalityValidator.new(
          validator_options.merge(attributes: :an_attribute)
        )
      ]
    end

    context 'with a less_than numericality validator' do
      let(:validator_options) { { less_than: option_value } }

      context 'with a symbol' do
        let(:option_value) { :a_symbol }

        it 'returns one less' do
          allow(model).to receive(:send).with(option_value).and_return(14)
          expect(instance.validation_max).to eq 13
        end
      end

      context 'with a proc' do
        let(:option_value) { proc { 10 } }

        it 'returns one less' do
          expect(instance.validation_max).to eq 9
        end
      end

      context 'with a number' do
        let(:option_value) { 8 }

        it 'returns one less' do
          expect(instance.validation_max).to eq 7
        end
      end
    end

    context 'with a less_than_or_equal_to numericality validator' do
      let(:validator_options) { { less_than_or_equal_to: option_value } }

      context 'with a symbol' do
        let(:option_value) { :a_symbol }

        it 'returns the instance method amount' do
          allow(model).to receive(:send).with(option_value).and_return(14)
          expect(instance.validation_max).to eq 14
        end
      end

      context 'with a proc' do
        let(:option_value) { proc { 10 } }

        it 'returns the proc amount' do
          expect(instance.validation_max).to eq 10
        end
      end

      context 'with a number' do
        let(:option_value) { 8 }

        it 'returns the number' do
          expect(instance.validation_max).to eq 8
        end
      end
    end
  end
end

