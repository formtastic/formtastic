# encoding: utf-8
require 'spec_helper'

describe 'Formtastic::Util' do

  describe '.deprecated_version_of_rails?' do
    
    subject { Formtastic::Util.deprecated_version_of_rails? }
    
    context '4.1.0' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("4.1.0") } }
      it 'should be false' do
        expect(subject).to be_falsey
      end
    end

    context '4.1.1' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("4.1.1") } }
      it 'should be false' do
        expect(subject).to be_falsey
      end
    end

    context '4.2.0' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("4.2.0") } }
      it 'should be false' do
        expect(subject).to be_falsey
      end
    end

    context '5.0.0' do
      before { allow(Formtastic::Util).to receive(:rails_version) { Gem::Version.new("5.0.0") } }
      it 'should be true' do
        expect(subject).to be_falsey
      end
    end
  end
end
