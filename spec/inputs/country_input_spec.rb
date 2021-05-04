# encoding: utf-8
require 'spec_helper'

RSpec.describe 'country input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActiveSupport::SafeBuffer.new ''
    mock_everything
  end

  describe "when country_select is not available as a helper from a plugin" do

    it "should raise an error, sugesting the author installs a plugin" do
      expect {
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:country, :as => :country))
        end
      }.to raise_error(Formtastic::Inputs::CountryInput::CountrySelectPluginMissing)
    end

  end

  describe "when country_select is available as a helper (from a plugin)" do

    before do
      concat(semantic_form_for(@new_post) do |builder|
        allow(builder).to receive(:country_select).and_return("<select><option>...</option></select>".html_safe)
        concat(builder.input(:country, :as => :country))
      end)
    end

    it_should_have_input_wrapper_with_class("country")
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_id("post_country_input")

    # TODO -- needs stubbing inside the builder block, tricky!
    #it_should_apply_error_logic_for_input_type(:country)

    it 'should generate a label for the input' do
      expect(output_buffer).to have_tag('form li label')
      expect(output_buffer).to have_tag('form li label[@for="post_country"]')
      expect(output_buffer).to have_tag('form li label', :text => /Country/)
    end

    it "should generate a select" do
      expect(output_buffer).to have_tag("form li select")
    end

  end

  describe ":priority_countries option" do

    it "should be passed down to the country_select helper when provided" do
      priority_countries = ["Foo", "Bah"]
      semantic_form_for(@new_post) do |builder|
        allow(builder).to receive(:country_select).and_return("<select><option>...</option></select>".html_safe)
        expect(builder).to receive(:country_select).with(:country, priority_countries, {}, {:id => "post_country", :required => false, :autofocus => false, :readonly => false}).and_return("<select><option>...</option></select>".html_safe)

        concat(builder.input(:country, :as => :country, :priority_countries => priority_countries))
      end
    end

    it "should default to the @@priority_countries config when absent" do
      priority_countries = Formtastic::FormBuilder.priority_countries
      expect(priority_countries).not_to be_empty
      expect(priority_countries).not_to be_nil

      semantic_form_for(@new_post) do |builder|
        allow(builder).to receive(:country_select).and_return("<select><option>...</option></select>".html_safe)
        expect(builder).to receive(:country_select).with(:country, priority_countries, {}, {:id => "post_country", :required => false, :autofocus => false, :readonly => false}).and_return("<select><option>...</option></select>".html_safe)

        concat(builder.input(:country, :as => :country))
      end
    end

  end

  describe "when namespace is provided" do

    before do
      @output_buffer = ActiveSupport::SafeBuffer.new ''
      mock_everything

      concat(semantic_form_for(@new_post, :namespace => 'context2') do |builder|
        allow(builder).to receive(:country_select).and_return("<select><option>...</option></select>".html_safe)
        expect(builder).to receive(:country_select).with(:country, [], {}, {:id => "context2_post_country", :required => false, :autofocus => false, :readonly => false}).and_return("<select><option>...</option></select>".html_safe)
        concat(builder.input(:country, :priority_countries => []))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_post_country_input")
    it_should_have_label_for("context2_post_country")

  end

  describe "matching" do

    describe "when the attribute is 'country'" do

      before do
        concat(semantic_form_for(@new_post) do |builder|
          allow(builder).to receive(:country_select).and_return("<select><option>...</option></select>".html_safe)
          concat(builder.input(:country))
        end)
      end

      it "should render a country input" do
        expect(output_buffer).to have_tag "form li.country"
      end
    end

    describe "whent the attribute is 'country_something'" do

      before do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:country_subdivision))
          concat(builder.input(:country_code))
        end)
      end

      it "should render a country input" do
        expect(output_buffer).not_to have_tag "form li.country"
        expect(output_buffer).to have_tag "form li.string", :count => 2
      end

    end

  end

end

