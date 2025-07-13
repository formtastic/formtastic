# frozen_string_literal: true
require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/formtastic/form/form_generator'

RSpec.describe Formtastic::FormGenerator do

  include FormtasticSpecHelper

  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    prepare_destination
    mock_everything
    allow(::Post).to receive(:reflect_on_all_associations).with(:belongs_to).and_return([
      double('reflection', :name => :author, :options => {}, :klass => ::Author, :macro => :belongs_to),
      double('reflection', :name => :reviewer, :options => {:class_name => 'Author'}, :klass => ::Author, :macro => :belongs_to),
      double('reflection', :name => :main_post, :options => {}, :klass => ::Post, :macro => :belongs_to),
      double('reflection', :name => :attachment, :options => {:polymorphic => true}, :macro => :belongs_to),
    ])
  end

  after do
    FileUtils.rm_rf(File.expand_path("../../../../../tmp", __FILE__))
  end

  describe 'without model' do
    it 'should raise Thor::RequiredArgumentMissingError' do
      expect { run_generator }.to raise_error(Thor::RequiredArgumentMissingError)
    end
  end

  describe 'with existing model' do
    it 'should not raise an exception' do
      expect { run_generator %w(Post) }.not_to raise_error
    end
  end

  describe 'with attributes' do
    before { run_generator %w(Post title:string author:references) }

    describe 'render only the specified attributes' do
      subject { file('app/views/posts/_form.html.erb') }
      it { is_expected.to exist }
      it { is_expected.to contain "<%= f.input :title %>" }
      it { is_expected.to contain "<%= f.input :author %>" }
      it { is_expected.not_to contain "<%= f.input :main_post %>" }
    end
  end

  describe 'without attributes' do
    before { run_generator %w(Post) }

    subject { file('app/views/posts/_form.html.erb') }

    describe 'content_columns' do
      it { is_expected.to contain "<%= f.input :title %>" }
      it { is_expected.to contain "<%= f.input :body %>" }
      it { is_expected.not_to contain "<%= f.input :created_at %>" }
      it { is_expected.not_to contain "<%= f.input :updated_at %>" }
    end

    describe 'reflection_on_association' do
      it { is_expected.to contain "<%= f.input :author %>" }
      it { is_expected.to contain "<%= f.input :reviewer %>" }
      it { is_expected.to contain "<%= f.input :main_post %>" }
      it { is_expected.not_to contain "<%= f.input :attachment %>" }
    end
  end

  describe 'with template engine option' do
    describe 'erb' do
      before { run_generator %w(Post --template-engine erb) }

      describe 'app/views/posts/_form.html.erb' do
        subject { file('app/views/posts/_form.html.erb') }
        it { is_expected.to exist }
        it { is_expected.to contain "<%= semantic_form_for @post do |f| %>" }
      end
    end

    describe 'haml' do

      describe 'app/views/posts/_form.html.haml' do
        before { run_generator %w(Post --template-engine haml) }
        subject { file('app/views/posts/_form.html.haml') }
        it { is_expected.to exist }
        it { is_expected.to contain "= semantic_form_for @post do |f|" }
      end

      context 'with copy option' do
        describe 'app/views/posts/_form.html.haml' do
          before { run_generator %w(Post --copy --template-engine haml) }
          subject { file('app/views/posts/_form.html.haml') }
          it { is_expected.not_to exist }
        end
      end

    end

    describe 'slim' do
      before { run_generator %w(Post --template-engine slim) }

      describe 'app/views/posts/_form.html.slim' do
        subject { file('app/views/posts/_form.html.slim') }
        it { is_expected.to exist }
        it { is_expected.to contain "= semantic_form_for @post do |f|" }
      end
    end
  end

  describe 'with copy option' do
    before { run_generator %w(Post --copy) }

    describe 'app/views/posts/_form.html.erb' do
      subject { file('app/views/posts/_form.html.erb') }
      it { is_expected.not_to exist }
    end
  end

  describe 'with controller option' do
    before { run_generator %w(Post --controller admin/posts) }

    describe 'app/views/admin/posts/_form.html.erb' do
      subject { file('app/views/admin/posts/_form.html.erb') }
      it { is_expected.to exist }
    end
  end
end
