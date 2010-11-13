# encoding: utf-8
require 'spec_helper'

describe 'radio input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'for belongs_to association' do
    before do
      @form = semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :radio, :value_as_class => true))
      end
    end

    it_should_have_input_wrapper_with_class("radio")
    it_should_have_input_wrapper_with_id("post_author_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:radio)
    it_should_use_the_collection_when_provided(:radio, 'input')

    it 'should generate a legend containing a label with text for the input' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag('form li fieldset legend.label label')
      output_buffer.should have_tag('form li fieldset legend.label label', /Author/)
    end

    it 'should not link the label within the legend to any input' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should_not have_tag('form li fieldset legend label[@for]')
    end

    it 'should generate an ordered list with a list item for each choice' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag('form li fieldset ol')
      output_buffer.should have_tag('form li fieldset ol li', :count => ::Author.all.size)
    end

    it 'should have one option with a "checked" attribute' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag('form li input[@checked]', :count => 1)
    end

    describe "each choice" do

      it 'should contain a label for the radio input with a nested input and label text' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Author.all.each do |author|
          output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_id_#{author.id}']")
        end
      end

      it 'should use values as li.class when value_as_class is true' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Author.all.each do |author|
          output_buffer.should have_tag("form li fieldset ol li.author_#{author.id} label")
        end
      end

      it "should have a radio input" do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Author.all.each do |author|
          output_buffer.should have_tag("form li fieldset ol li label input#post_author_id_#{author.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@type='radio']")
          output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='post[author_id]']")
        end
      end

      it "should mark input as checked if it's the the existing choice" do
        @new_post.author_id.should == @bob.id
        @new_post.author.id.should == @bob.id
        @new_post.author.should == @bob

        form = semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio))
        end

        output_buffer.concat(form) if Formtastic::Util.rails3?
        output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
      end

      it "should not contain invalid HTML attributes" do

        form = semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio))
        end

        output_buffer.concat(form) if Formtastic::Util.rails3?
        output_buffer.should_not have_tag("form li fieldset ol li input[@find_options]")
      end

    end

    describe 'and no object is given' do
      before(:each) do
        output_buffer.replace ''
        @form = semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :radio, :collection => ::Author.all))
        end
      end

      it 'should generate a fieldset with legend' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('form li fieldset legend', /Author/)
      end

      it 'should generate an li tag for each item in the collection' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('form li fieldset ol li', :count => ::Author.all.size)
      end

      it 'should generate labels for each item' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Author.all.each do |author|
          output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='project_author_id_#{author.id}']")
        end
      end

      it 'should html escape the label string' do
        output_buffer.replace ''
        form = semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :radio, :collection => [["<b>Item 1</b>", 1], ["<b>Item 2</b>", 2]]))
        end
        output_buffer.concat(form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('form li fieldset ol li label') do |label|
          label.body.should match /&lt;b&gt;Item [12]&lt;\/b&gt;$/
        end
      end

      it 'should generate inputs for each item' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Author.all.each do |author|
          output_buffer.should have_tag("form li fieldset ol li label input#project_author_id_#{author.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@type='radio']")
          output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='project[author_id]']")
        end
      end
    end
  end

  describe "with i18n of the legend label" do

    before do
      ::I18n.backend.store_translations :en, :formtastic => { :labels => { :post => { :authors => "Translated!" }}}

      Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true
      @new_post.stub!(:author_ids).and_return(nil)
      @form = semantic_form_for(@new_post) do |builder|
        concat(builder.input(:authors, :as => :radio))
      end
    end

    after do
      ::I18n.backend.reload!
      Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false
    end

    it "should do foo" do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("legend.label label", /Translated/)
    end

  end

  describe "when :label option is set" do
    before do
      @new_post.stub!(:author_ids).and_return(nil)
      @form = semantic_form_for(@new_post) do |builder|
        concat(builder.input(:authors, :as => :radio, :label => 'The authors'))
      end
    end

    it "should output the correct label title" do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("legend.label label", /The authors/)
    end
  end

  describe "when :label option is false" do
    before do
      @output_buffer = ''
      @new_post.stub!(:author_ids).and_return(nil)
      @form = semantic_form_for(@new_post) do |builder|
        concat(builder.input(:authors, :as => :radio, :label => false))
      end
    end

    it "should not output the legend" do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should_not have_tag("legend.label")
    end
  end

  describe "when :required option is true" do
    before do
      @new_post.stub!(:author_ids).and_return(nil)
      @form = semantic_form_for(@new_post) do |builder|
        concat(builder.input(:authors, :as => :radio, :required => true))
      end
    end

    it "should output the correct label title" do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag("legend.label label abbr")
    end
  end

  describe "when :namespace is given on form" do
    before do
      @output_buffer = ''
      @new_post.stub!(:author_ids).and_return(nil)
      @form = semantic_form_for(@new_post, :namespace => "custom_prefix") do |builder|
        concat(builder.input(:authors, :as => :radio, :label => ''))
      end

      @form.should match(/for="custom_prefix_post_author_ids_(\d+)"/)
      @form.should match(/id="custom_prefix_post_author_ids_(\d+)"/)
    end
    it_should_have_input_wrapper_with_id("custom_prefix_post_authors_input")
  end

end
