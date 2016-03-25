require 'fast_spec_helper'
require 'inputs/base/validations'

class MyInput
  include Formtastic::Inputs::Base::Validations
end

describe MyInput do
  let(:builder) { double }
  let(:template) { double }
  let(:model_class) { double }
  let(:model) { double(:class => model_class) }
  let(:model_name) { "post" }
  let(:method) { double }
  let(:options) { Hash.new }
  let(:validator) { double }
  let(:instance) { MyInput.new(builder, template, model, model_name, method, options) }

  describe '#required?' do
    context 'with a single validator' do
      before :each do
        allow(instance).to receive(:validations?).and_return(:true)
        allow(instance).to receive(:validations).and_return([validator])
      end

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
      context 'with a on create presence validator and a on update presence validator' do
        let (:validator1) { double(options: {on: :create}, kind: :presence) }
        let (:validator2) { double(options: {}, kind: :presence) }

        before :each do
          allow(model).to receive(:new_record?).and_return(false)
          allow(instance).to receive(:validations?).and_return(:true)
          allow(instance).to receive(:validations).and_return([validator1, validator2])
        end

        it 'is required' do
          expect(instance.required?).to be_truthy
        end
      end

      context 'with a on create presence validator and a presence validator' do
        let (:validator1) { double(options: {on: :create}, kind: :presence) }
        let (:validator2) { double(options: {}, kind: :presence) }

        before :each do
          allow(model).to receive(:new_record?).and_return(false)
          allow(instance).to receive(:validations?).and_return(:true)
          allow(instance).to receive(:validations).and_return([validator1, validator2])
        end

        it 'is required' do
          expect(instance.required?).to be_truthy
        end
      end

      context 'with a on create presence validator and a allow blank inclusion validator' do
        let (:validator1) { double(options: {on: :create}, kind: :presence) }
        let (:validator2) { double(options: {allow_blank: true}, kind: :inclusion) }

        before :each do
          allow(model).to receive(:new_record?).and_return(false)
          allow(instance).to receive(:validations?).and_return(:true)
          allow(instance).to receive(:validations).and_return([validator1, validator2])
        end

        it 'is required' do
          expect(instance.required?).to be_falsey
        end
      end
    end
  end
end

