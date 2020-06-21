# encoding: utf-8
require 'spec_helper'

RSpec.describe 'Formtastic::Helpers::FormHelper.builder' do

  include FormtasticSpecHelper

  class MyCustomFormBuilder < Formtastic::FormBuilder
  end

  # TODO should be a separate spec for custom inputs
  class Formtastic::Inputs::AwesomeInput
    include Formtastic::Inputs::Base
    def to_html
      "Awesome!"
    end
  end

  before do
    @output_buffer = ''
    mock_everything
  end

  it 'is the Formtastic::FormBuilder by default' do
    expect(Formtastic::Helpers::FormHelper.builder).to eq(Formtastic::FormBuilder)
  end

  it 'can be configured to use your own custom form builder' do
    # Set it to a custom builder class
    Formtastic::Helpers::FormHelper.builder = MyCustomFormBuilder
    expect(Formtastic::Helpers::FormHelper.builder).to eq(MyCustomFormBuilder)

    # Reset it to the default
    Formtastic::Helpers::FormHelper.builder = Formtastic::FormBuilder
    expect(Formtastic::Helpers::FormHelper.builder).to eq(Formtastic::FormBuilder)
  end

  it 'should allow custom settings per form builder subclass' do
    with_config(:all_fields_required_by_default, true) do
      MyCustomFormBuilder.all_fields_required_by_default = false

      expect(MyCustomFormBuilder.all_fields_required_by_default).to be_falsey
      expect(Formtastic::FormBuilder.all_fields_required_by_default).to be_truthy
    end
  end

  describe "when using a custom builder" do

    before do
      allow(@new_post).to receive(:title)
      Formtastic::Helpers::FormHelper.builder = MyCustomFormBuilder
    end

    after do
      Formtastic::Helpers::FormHelper.builder = Formtastic::FormBuilder
    end

    describe "semantic_form_for" do

      it "should yield an instance of the custom builder" do
        semantic_form_for(@new_post) do |builder|
          expect(builder.class).to be(MyCustomFormBuilder)
        end
      end

      # TODO should be a separate spec for custom inputs
      it "should allow me to call my custom input" do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :awesome))
        end
      end

      # See: https://github.com/formtastic/formtastic/issues/657
      it "should not conflict with navigasmic" do
        allow_any_instance_of(self.class).to receive(:builder).and_return('navigasmic')

        expect { semantic_form_for(@new_post) { |f| } }.not_to raise_error
      end

      it "should use the custom builder's skipped_columns config for inputs" do
        class AnotherCustomFormBuilder < Formtastic::FormBuilder
          configure :skipped_columns, [:title, :created_at]
        end
        #AnotherCustomFormBuilder.skipped_columns = [:title, :created_at]

        concat(semantic_form_for(@new_post, builder: AnotherCustomFormBuilder) do |builder|
          concat(builder.inputs)
        end)

        expect(output_buffer).to_not have_tag('input#post_title')
        expect(output_buffer).to_not have_tag('li#post_created_at_input')
        expect(output_buffer).to have_tag('textarea#post_body')
      end
    end

    describe "fields_for" do

      it "should yield an instance of the parent form builder" do
        allow(@new_post).to receive(:comment).and_return([@fred])
        allow(@new_post).to receive(:comment_attributes=)
        semantic_form_for(@new_post, :builder => MyCustomFormBuilder) do |builder|
          expect(builder.class).to be(MyCustomFormBuilder)

          builder.fields_for(:comment) do |nested_builder|
            expect(nested_builder.class).to be(MyCustomFormBuilder)
          end
        end
      end

    end



  end

  describe "when using a builder passed to form options" do

    describe "fields_for" do

      it "should yield an instance of the parent form builder" do
        allow(@new_post).to receive(:author_attributes=)
        semantic_form_for(@new_post, :builder => MyCustomFormBuilder) do |builder|
          builder.fields_for(:author) do |nested_builder|
            expect(nested_builder.class).to be(MyCustomFormBuilder)
          end
        end
      end

    end

  end
end
