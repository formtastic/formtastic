# frozen_string_literal: true
require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/formtastic/install/install_generator'

RSpec.describe Formtastic::InstallGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'no arguments' do
    before { run_generator  }

    describe 'config/initializers/formtastic.rb' do
      subject { file('config/initializers/formtastic.rb') }
      it { is_expected.to exist }
      it { is_expected.to contain "#" }
    end

    describe 'lib/templates/erb/scaffold/_form.html.erb' do
      subject { file('lib/templates/erb/scaffold/_form.html.erb') }
      it { is_expected.to exist }
      it { is_expected.to contain "<%%= semantic_form_for @<%= singular_name %> do |f| %>" }
    end
  end

  describe 'haml' do
    before { run_generator %w(--template-engine haml) }

    describe 'lib/templates/erb/scaffold/_form.html.haml' do
      subject { file('lib/templates/haml/scaffold/_form.html.haml') }
      it { is_expected.to exist }
      it { is_expected.to contain "= semantic_form_for @<%= singular_name %> do |f|" }
    end
  end

  describe 'slim' do
    before { run_generator %w(--template-engine slim) }

    describe 'lib/templates/erb/scaffold/_form.html.slim' do
      subject { file('lib/templates/slim/scaffold/_form.html.slim') }
      it { is_expected.to exist }
      it { is_expected.to contain "= semantic_form_for @<%= singular_name %> do |f|" }
    end
  end
end
