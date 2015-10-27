require 'spec_helper'

require 'generators/formtastic/input/input_generator'

describe Formtastic::InputGenerator do
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
      lambda { run_generator }.should raise_error(Thor::RequiredArgumentMissingError)
    end
  end

  describe "input generator with underscore definition" do
    before { run_generator %w(hat_size)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { should exist}
      it { should contain "class HatSizeInput"}
      it { should contain "def to_html"}
      it { should contain "include Formtastic::Inputs::Base"}
      it { should_not contain "super"}
    end
  end

  describe "input generator with camelcase definition" do
    before { run_generator %w(HatSize)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { should exist}
      it { should contain "class HatSizeInput"}
    end
  end

  describe "input generator with camelcase Input name sufixed" do
    before { run_generator %w(HatSizeInput)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { should exist}
      it { should contain "class HatSizeInput"}
    end
  end

  describe "input generator with underscore _input name sufixed" do
    before { run_generator %w(hat_size_input)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { should exist}
      it { should contain "class HatSizeInput"}
    end
  end

  describe "input generator with underscore input name sufixed" do
    before { run_generator %w(hat_sizeinput)}

    describe 'generate an input in its respective folder' do
      subject{ file('app/inputs/hat_size_input.rb')}
      it { should exist}
      it { should contain "class HatSizeInput"}
    end
  end

  describe "override an existing input using extend" do
    before { run_generator %w(string --extend)}

    describe 'app/inputs/string_input.rb' do
      subject{ file('app/inputs/string_input.rb')}
      it { should exist }
      it { should contain "class StringInput < Formtastic::Inputs::StringInput" }
      it { should contain "def to_html" }
      it { should_not contain "include Formtastic::Inputs::Base" }
      it { should contain "super" }
      it { should_not contain "def input_html_options" }
    end
  end

  describe "extend an existing input" do
    before { run_generator %w(FlexibleText --extend string)}

    describe 'app/inputs/flexible_text_input.rb' do
      subject{ file('app/inputs/flexible_text_input.rb')}
      it { should contain "class FlexibleTextInput < Formtastic::Inputs::StringInput" }
      it { should contain "def input_html_options" }
      it { should_not contain "include Formtastic::Inputs::Base" }
      it { should_not contain "def to_html" }
    end
  end

  describe "provide a slashed namespace" do
    before { run_generator %w(stuff/foo)}

    describe 'app/inputs/stuff/foo_input.rb' do
      subject{ file('app/inputs/stuff/foo_input.rb')}
      it {should exist}
      it { should contain "class Stuff::FooInput" }
      it { should contain "include Formtastic::Inputs::Base" }
    end
  end

  describe "provide a camelized namespace" do
    before { run_generator %w(Stuff::Foo)}

    describe 'app/inputs/stuff/foo_input.rb' do
      subject{ file('app/inputs/stuff/foo_input.rb')}
      it {should exist}
      it { should contain "class Stuff::FooInput" }
      it { should contain "include Formtastic::Inputs::Base" }
    end
  end
end