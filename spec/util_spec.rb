# encoding: utf-8
require 'spec_helper'

describe 'Formtastic::Util' do

  describe '.deprecated_version_of_rails?' do
    
    subject { Formtastic::Util.deprecated_version_of_rails? }
    
    context '3.0.0' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("3.0.0") } }
      it 'should be true' do
        expect(subject).to be_true
      end
    end

    context '3.1.0' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("3.1.0") } }
      it 'should be true' do
        expect(subject).to be_true
      end
    end

    context '3.2.12' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("3.2.12") } }
      it 'should be true' do
        expect(subject).to be_true
      end
    end

    context '3.2.13' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("3.2.13") } }
      it 'should be true' do
        expect(subject).to be_false
      end
    end

    context '3.2.14' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("3.2.14") } }
      it 'should be true' do
        expect(subject).to be_false
      end
    end

    context '3.3.0' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("3.3.0") } }
      it 'should be true' do
        expect(subject).to be_false
      end
    end

    context '4.0.0' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("4.0.0") } }
      it 'should be true' do
        expect(subject).to be_false
      end
    end
  end
end
