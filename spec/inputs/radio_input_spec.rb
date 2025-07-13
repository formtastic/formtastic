# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'radio input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  describe 'for belongs_to association' do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :radio, :value_as_class => true, :required => true))
      end)
    end

    it_should_have_input_wrapper_with_class("radio")
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_id("post_author_input")
    it_should_have_a_nested_fieldset
    it_should_have_a_nested_fieldset_with_class('choices')
    it_should_have_a_nested_ordered_list_with_class('choices-group')
    it_should_apply_error_logic_for_input_type(:radio)
    it_should_use_the_collection_when_provided(:radio, 'input')

    it 'should generate a legend containing a label with text for the input' do
      expect(output_buffer.to_str).to have_tag('form li fieldset legend.label label')
      expect(output_buffer.to_str).to have_tag('form li fieldset legend.label label', :text => /Author/)
    end

    it 'should not link the label within the legend to any input' do
      expect(output_buffer.to_str).not_to have_tag('form li fieldset legend label[@for]')
    end

    it 'should generate an ordered list with a list item for each choice' do
      expect(output_buffer.to_str).to have_tag('form li fieldset ol')
      expect(output_buffer.to_str).to have_tag('form li fieldset ol li.choice', :count => ::Author.all.size)
    end

    it 'should have one option with a "checked" attribute' do
      expect(output_buffer.to_str).to have_tag('form li input[@checked]', :count => 1)
    end

    describe "each choice" do

      it 'should not give the choice label the .label class' do
        expect(output_buffer.to_str).not_to have_tag('li.choice label.label')
      end

      it 'should not add the required attribute to each input' do
        expect(output_buffer.to_str).not_to have_tag('li.choice input[@required]')
      end


      it 'should contain a label for the radio input with a nested input and label text' do
        ::Author.all.each do |author|
          expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', /#{author.to_label}/)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='post_author_id_#{author.id}']")
        end
      end

      it 'should use values as li.class when value_as_class is true' do
        ::Author.all.each do |author|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li.author_#{author.id} label")
        end
      end

      it "should have a radio input" do
        ::Author.all.each do |author|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input#post_author_id_#{author.id}")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@type='radio']")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@name='post[author_id]']")
        end
      end

      it "should mark input as checked if it's the the existing choice" do
        expect(@new_post.author_id).to eq(@bob.id)
        expect(@new_post.author.id).to eq(@bob.id)
        expect(@new_post.author).to eq(@bob)

        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio))
        end)

        expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@checked='checked']")
      end

      it "should mark the input as disabled if options attached for disabling" do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio, :collection => [["Test", 'test'], ["Try", "try", {:disabled => true}]]))
        end)

        expect(output_buffer.to_str).not_to have_tag("form li fieldset ol li label input[@value='test'][@disabled='disabled']")
        expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='try'][@disabled='disabled']")
      end

      it "should not contain invalid HTML attributes" do

        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio))
        end)

        expect(output_buffer.to_str).not_to have_tag("form li fieldset ol li input[@find_options]")
      end

    end

    describe 'and no object is given' do
      before(:example) do
        @output_buffer = ActionView::OutputBuffer.new ''
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :radio, :collection => ::Author.all))
        end)
      end

      it 'should generate a fieldset with legend' do
        expect(output_buffer.to_str).to have_tag('form li fieldset legend', :text => /Author/)
      end

      it 'should generate an li tag for each item in the collection' do
        expect(output_buffer.to_str).to have_tag('form li fieldset ol li', :count => ::Author.all.size)
      end

      it 'should generate labels for each item' do
        ::Author.all.each do |author|
          expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', :text => /#{author.to_label}/)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='project_author_id_#{author.id}']")
        end
      end

      it 'should html escape the label string' do
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :radio, :collection => [["<b>Item 1</b>", 1], ["<b>Item 2</b>", 2]]))
        end)
        expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', text: %r{<b>Item [12]</b>}, count: 2)
      end

      it 'should generate inputs for each item' do
        ::Author.all.each do |author|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input#project_author_id_#{author.id}")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@type='radio']")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@name='project[author_id]']")
        end
      end
    end
  end

  describe 'for a enum column' do
    before do
      allow(@new_post).to receive(:status) { 'inactive' }
      statuses = ActiveSupport::HashWithIndifferentAccess.new("active"=>0, "inactive"=>1)
      allow(@new_post.class).to receive(:statuses) { statuses }
      allow(@new_post).to receive(:defined_enums) { { "status" => statuses } }
    end

    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:status, :as => :radio))
      end)
    end

    it 'should have a radio input for each defined enum status' do
      expect(output_buffer.to_str).to have_tag("form li input[@name='post[status]'][@type='radio']", :count => @new_post.class.statuses.count)
      @new_post.class.statuses.each do |label, value|
        expect(output_buffer.to_str).to have_tag("form li input[@value='#{label}']")
        expect(output_buffer.to_str).to have_tag("form li label", :text => /#{label.humanize}/)
      end
    end

    it 'should have one radio input with a "checked" attribute' do
      expect(output_buffer.to_str).to have_tag("form li input[@name='post[status]'][@checked]", :count => 1)
    end
  end


  describe "with i18n of the legend label" do

    before do
      ::I18n.backend.store_translations :en, :formtastic => { :labels => { :post => { :authors => "Translated!" }}}

      with_config :i18n_lookups_by_default, true do
        allow(@new_post).to receive(:author_ids).and_return(nil)
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:authors, :as => :radio))
        end)
      end
    end

    after do
      ::I18n.backend.reload!
    end

    it "should do foo" do
      expect(output_buffer.to_str).to have_tag("legend.label label", :text => /Translated/)
    end

  end

  describe "when :label option is set" do
    before do
      allow(@new_post).to receive(:author_ids).and_return(nil)
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:authors, :as => :radio, :label => 'The authors'))
      end)
    end

    it "should output the correct label title" do
      expect(output_buffer.to_str).to have_tag("legend.label label", :text => /The authors/)
    end
  end

  describe "when :label option is false" do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      allow(@new_post).to receive(:author_ids).and_return(nil)
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:authors, :as => :radio, :label => false))
      end)
    end

    it "should not output the legend" do
      expect(output_buffer.to_str).not_to have_tag("legend.label")
      expect(output_buffer.to_str).not_to include("&gt;")
    end

    it "should not cause escaped HTML" do
      expect(output_buffer.to_str).not_to include("&gt;")
    end
  end

  describe "when :required option is true" do
    before do
      allow(@new_post).to receive(:author_ids).and_return(nil)
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:authors, :as => :radio, :required => true))
      end)
    end

    it "should output the correct label title" do
      expect(output_buffer.to_str).to have_tag("legend.label label abbr")
    end
  end

  describe "when :namespace is given on form" do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      allow(@new_post).to receive(:author_ids).and_return(nil)
      concat(semantic_form_for(@new_post, :namespace => "custom_prefix") do |builder|
        concat(builder.input(:authors, :as => :radio, :label => ''))
      end)

      expect(output_buffer.to_str).to match(/for="custom_prefix_post_author_ids_(\d+)"/)
      expect(output_buffer.to_str).to match(/id="custom_prefix_post_author_ids_(\d+)"/)
    end
    it_should_have_input_wrapper_with_id("custom_prefix_post_authors_input")
  end

  describe "when index is provided" do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.fields_for(:author, :index => 3) do |author|
          concat(author.input(:name, :as => :radio))
        end)
      end)
    end

    it 'should index the id of the wrapper' do
      expect(output_buffer.to_str).to have_tag("li#post_author_attributes_3_name_input")
    end

    it 'should index the id of the select tag' do
      expect(output_buffer.to_str).to have_tag("input#post_author_attributes_3_name_true")
      expect(output_buffer.to_str).to have_tag("input#post_author_attributes_3_name_false")
    end

    it 'should index the name of the select tag' do
      expect(output_buffer.to_str).to have_tag("input[@name='post[author_attributes][3][name]']")
    end

  end

  describe "when collection contains integers" do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(:project) do |builder|
        concat(builder.input(:author_id, :as => :radio, :collection => [1, 2, 3]))
      end)
    end

    it 'should output the correct labels' do
      expect(output_buffer.to_str).to have_tag("li.choice label", :text => /1/)
      expect(output_buffer.to_str).to have_tag("li.choice label", :text => /2/)
      expect(output_buffer.to_str).to have_tag("li.choice label", :text => /3/)
    end
  end

  describe "when collection contains symbols" do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(:project) do |builder|
        concat(builder.input(:author_id, :as => :radio, :collection => Set.new([["A", :a], ["B", :b], ["C", :c]])))
      end)
    end

    it 'should output the correct labels' do
      expect(output_buffer.to_str).to have_tag("li.choice label", :text => /A/)
      expect(output_buffer.to_str).to have_tag("li.choice label", :text => /B/)
      expect(output_buffer.to_str).to have_tag("li.choice label", :text => /C/)
    end
  end


end
