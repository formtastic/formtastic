# encoding: utf-8
require 'spec_helper'

describe 'iconish segments input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe "when object is provided" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:money, :as => :iconish_segments))
      end)
    end

    it_should_have_input_wrapper_with_class(:iconish_segments)
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_class(:stringish)
    it_should_have_input_wrapper_with_id("post_money_input")
    it_should_have_label_with_text(/Money/)
    it_should_have_label_for("post_money")
    it_should_have_input_with_id("post_money")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("post[money]")
    it_should_apply_custom_input_attributes_when_input_html_provided(:string)
    it_should_apply_error_logic_for_input_type(:string)

    it "should have input groups wrapper with class 'iconish-segments-controls'" do
      output_buffer.should have_tag("form li div.iconish-segments-controls")
    end

  end

  context "when :input_prepend is provided" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:money, :as => :iconish_segments, :input_prepend => ''))
      end)
    end

    it "should have input groups wrapper with class 'iconish-segments-controls input-prepend'" do
      output_buffer.should have_tag("form li div.iconish-segments-controls.input-prepend")
    end

    it "should have a span with class 'add-on'" do
      output_buffer.should have_tag("form li div span.add-on")
    end

    it "prepends a span element to the input" do
      output_buffer.should have_tag("form li div span + input")
    end

    context "and is a String" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:money, :as => :iconish_segments, :input_prepend => '$'))
        end)
      end

      it "should have a span with text '$'" do
        output_buffer.should have_tag("form li div span", '$')
      end

    end

    context "and is a Proc" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:money, :as => :iconish_segments, :input_prepend => lambda { '$' }))
        end)
      end

      it "should have a span containing the Proc's output" do
        output_buffer.should have_tag("form li div span", '$')
      end

    end

  end

  context "when :input_append is provided" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:money, :as => :iconish_segments, :input_append => ''))
      end)
    end

    it "should have input groups wrapper with class 'iconish-segments-controls input-append'" do
      output_buffer.should have_tag("form li div.iconish-segments-controls.input-append")
    end

    it "should have a span with class 'add-on'" do
      output_buffer.should have_tag("form li div span.add-on")
    end

    it "appends a span element to the input" do
      output_buffer.should have_tag("form li div input + span")
    end

    context "and is a String" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:money, :as => :iconish_segments, :input_append => '.00'))
        end)
      end

      it "should have a span with text '.00'" do
        output_buffer.should have_tag("form li div span", '.00')
      end

    end

    context "and is a Proc" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:money, :as => :iconish_segments, :input_append => lambda { '.00' }))
        end)
      end

      it "should have a span containing the Proc's output" do
        output_buffer.should have_tag("form li div input + span", '.00')
      end

    end

    context "and is a Proc that outputs a button" do
      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:money, :as => :iconish_segments, :input_append => lambda { button_tag('Transfer') }))
        end)
      end

      it "should have a button with text 'Send'" do
        output_buffer.should have_tag("form li div input + button", 'Transfer')
      end

    end

  end

  context "when both :input_prepend and :input_append are provided" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:money, :as => :iconish_segments, :input_prepend => '', :input_append => ''))
      end)
    end

    it "should have input groups wrapper with class 'iconish-segments-controls input-prepend input-append'" do
      output_buffer.should have_tag("form li div.iconish-segments-controls.input-prepend.input-append")
    end

  end

end