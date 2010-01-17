# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'currency input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe "when currency_select is not available as a helper from a plugin" do

    it "should raise an error, sugesting the author installs a plugin" do
      lambda {
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:currency, :as => :currency))
        end
      }.should raise_error
    end

  end

  describe "when currency_select is available as a helper (from a plugin)" do

    before do
      semantic_form_for(@new_post) do |builder|
        builder.stub!(:currency_select).and_return("<select><option>...</option></select>")
        concat(builder.input(:currency, :as => :currency))
      end
    end

    it_should_have_input_wrapper_with_class("currency")
    it_should_have_input_wrapper_with_id("post_currency_input")

    # TODO -- needs stubbing inside the builder block, tricky!
    #it_should_apply_error_logic_for_input_type(:currency)

    it 'should generate a label for the input' do
      output_buffer.should have_tag('form li label')
      output_buffer.should have_tag('form li label[@for="post_currency"]')
      output_buffer.should have_tag('form li label', /Currency/)
    end

    it "should generate a select" do
      output_buffer.should have_tag("form li select")
    end

  end

  describe ":priority_currencies option" do

    it "should be passed down to the currency_select helper when provided" do
      priority_currencies = ["Foo", "Bah"]
      semantic_form_for(@new_post) do |builder|
        builder.stub!(:currency_select).and_return("<select><option>...</option></select>")
        builder.should_receive(:currency_select).with(:currency, priority_currencies, {}, {}).and_return("<select><option>...</option></select>")

        concat(builder.input(:currency, :as => :currency, :priority_currencies => priority_currencies))
      end
    end

    it "should default to the @@priority_currencies config when absent" do
      priority_currencies = ::Formtastic::SemanticFormBuilder.priority_currencies
      priority_currencies.should_not be_empty
      priority_currencies.should_not be_nil

      semantic_form_for(@new_post) do |builder|
        builder.stub!(:currency_select).and_return("<select><option>...</option></select>")
        builder.should_receive(:currency_select).with(:currency, priority_currencies, {}, {}).and_return("<select><option>...</option></select>")

        concat(builder.input(:currency, :as => :currency))
      end
    end

  end

end

