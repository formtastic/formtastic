require 'spec_helper'

require 'generators/formtastic/input/input_generator'

RSpec.describe Formtastic::InputGenerator do
  include FormtasticSpecHelper

  destination File.expand_path("../../../../../tmp", __FILE__)

  before do
    prepare_destination
  end

  after do
    FileUtils.rm_rf(File.expand_path("../../../../../tmp", __FILE__))
  end

  describe 'without file name' do
    it 'should raise Thor::RequiredArgumentMissingError' do
      expect { run_generator }.to raise_error(Thor::RequiredArgumentMissingError)
    end
  end

  describe "input generator with underscore definition" do
    before { run_generator %w(hat_size)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { is_expected.to exist}
      it { is_expected.to contain "class HatSizeInput"}
      it { is_expected.to contain "def to_html"}
      it { is_expected.to contain "include Formtastic::Inputs::Base"}
      it { is_expected.not_to contain "super"}
    end
  end

  describe "input generator with camelcase definition" do
    before { run_generator %w(HatSize)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { is_expected.to exist}
      it { is_expected.to contain "class HatSizeInput"}
    end
  end

  describe "input generator with camelcase Input name sufixed" do
    before { run_generator %w(HatSizeInput)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { is_expected.to exist}
      it { is_expected.to contain "class HatSizeInput"}
    end
  end

  describe "input generator with underscore _input name sufixed" do
    before { run_generator %w(hat_size_input)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { is_expected.to exist}
      it { is_expected.to contain "class HatSizeInput"}
    end
  end

  describe "input generator with underscore input name sufixed" do
    before { run_generator %w(hat_sizeinput)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { is_expected.to exist}
      it { is_expected.to contain "class HatSizeInput"}
    end
  end

  describe "override an existing input using extend" do
    before { run_generator %w(string --extend)}

    describe 'app/inputs/string_input.rb' do
      subject{ file('app/inputs/string_input.rb')}
      it { is_expected.to exist }
      it { is_expected.to contain "class StringInput < Formtastic::Inputs::StringInput" }
      it { is_expected.to contain "def to_html" }
      it { is_expected.not_to contain "include Formtastic::Inputs::Base" }
      it { is_expected.to contain "super" }
      it { is_expected.not_to contain "def input_html_options" }
    end
  end

  describe "extend an existing input" do
    before { run_generator %w(FlexibleText --extend string)}

    describe 'app/inputs/flexible_text_input.rb' do
      subject{ file('app/inputs/flexible_text_input.rb')}
      it { is_expected.to contain "class FlexibleTextInput < Formtastic::Inputs::StringInput" }
      it { is_expected.to contain "def input_html_options" }
      it { is_expected.not_to contain "include Formtastic::Inputs::Base" }
      it { is_expected.not_to contain "def to_html" }
    end
  end

  describe "provide a slashed namespace" do
    before { run_generator %w(stuff/foo)}

    describe 'app/inputs/stuff/foo_input.rb' do
      subject{ file('app/inputs/stuff/foo_input.rb')}
      it {is_expected.to exist}
      it { is_expected.to contain "class Stuff::FooInput" }
      it { is_expected.to contain "include Formtastic::Inputs::Base" }
    end
  end

  describe "provide a camelized namespace" do
    before { run_generator %w(Stuff::Foo)}

    describe 'app/inputs/stuff/foo_input.rb' do
      subject{ file('app/inputs/stuff/foo_input.rb')}
      it {is_expected.to exist}
      it { is_expected.to contain "class Stuff::FooInput" }
      it { is_expected.to contain "include Formtastic::Inputs::Base" }
    end
  end
end