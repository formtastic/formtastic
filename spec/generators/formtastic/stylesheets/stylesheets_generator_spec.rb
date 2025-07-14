# frozen_string_literal: true
require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/formtastic/stylesheets/stylesheets_generator'

RSpec.describe Formtastic::StylesheetsGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'no arguments' do
    before { run_generator  }

    describe 'app/assets/stylesheets/formtastic.css' do
      subject { file('app/assets/stylesheets/formtastic.css') }
      it { is_expected.to exist }
      it { is_expected.to contain ".formtastic" }
    end
  end
end
