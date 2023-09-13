# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'check_boxes input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  describe 'for a has_many association' do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@fred) do |builder|
        concat(builder.input(:posts, :as => :check_boxes, :value_as_class => true, :required => true))
      end)
    end

    it_should_have_input_wrapper_with_class("check_boxes")
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_id("author_posts_input")
    it_should_have_a_nested_fieldset
    it_should_have_a_nested_fieldset_with_class('choices')
    it_should_have_a_nested_ordered_list_with_class('choices-group')
    it_should_apply_error_logic_for_input_type(:check_boxes)
    it_should_call_find_on_association_class_when_no_collection_is_provided(:check_boxes)
    it_should_use_the_collection_when_provided(:check_boxes, 'input[@type="checkbox"]')

    it 'should generate a legend containing a label with text for the input' do
      expect(output_buffer.to_str).to have_tag('form li fieldset legend.label label')
      expect(output_buffer.to_str).to have_tag('form li fieldset legend.label label', :text => /Posts/)
    end

    it 'should not link the label within the legend to any input' do
      expect(output_buffer.to_str).not_to have_tag('form li fieldset legend label[@for^="author_post_ids_"]')
    end

    it 'should generate an ordered list with an li.choice for each choice' do
      expect(output_buffer.to_str).to have_tag('form li fieldset ol')
      expect(output_buffer.to_str).to have_tag('form li fieldset ol li.choice input[@type=checkbox]', :count => ::Post.all.size)
    end

    it 'should have one option with a "checked" attribute' do
      expect(output_buffer.to_str).to have_tag('form li input[@checked]', :count => 1)
    end

    it 'should not generate hidden inputs with default value blank' do
      expect(output_buffer.to_str).not_to have_tag("form li fieldset ol li label input[@type='hidden'][@value='']")
    end

    it 'should not render hidden inputs inside the ol' do
      expect(output_buffer.to_str).not_to have_tag("form li fieldset ol li input[@type='hidden']")
    end

    it 'should render one hidden input for each choice outside the ol' do
      expect(output_buffer.to_str).to have_tag("form li fieldset > input[@type='hidden']", :count => 1)
    end

    describe "each choice" do

      it 'should not give the choice label the .label class' do
        expect(output_buffer.to_str).not_to have_tag('li.choice label.label')
      end

      it 'should not be marked as required' do
        expect(output_buffer.to_str).not_to have_tag('li.choice input[@required]')
      end

      it 'should contain a label for the radio input with a nested input and label text' do
        ::Post.all.each do |post|
          expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', :text => /#{post.to_label}/)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='author_post_ids_#{post.id}']")
        end
      end

      it 'should use values as li.class when value_as_class is true' do
        ::Post.all.each do |post|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li.post_#{post.id} label")
        end
      end

      it 'should have a checkbox input but no hidden field for each post' do
        ::Post.all.each do |post|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => 1)
        end
      end

      it 'should have a hidden field with an empty array value for the collection to allow clearing of all checkboxes' do
        expect(output_buffer.to_str).to have_tag("form li fieldset > input[@type=hidden][@name='author[post_ids][]'][@value='']", :count => 1)
      end

      it 'the hidden field with an empty array value should be followed by the ol' do
        expect(output_buffer.to_str).to have_tag("form li fieldset > input[@type=hidden][@name='author[post_ids][]'][@value=''] + ol", :count => 1)
      end

      it 'should not have a hidden field with an empty string value for the collection' do
        expect(output_buffer.to_str).not_to have_tag("form li fieldset > input[@type=hidden][@name='author[post_ids]'][@value='']", :count => 1)
      end

      it 'should have a checkbox and a hidden field for each post with :hidden_field => true' do
        @output_buffer = ActionView::OutputBuffer.new ''

        concat(semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :hidden_fields => true, :value_as_class => true))
        end)

        ::Post.all.each do |post|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => 2)
          expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', :text => /#{post.to_label}/)
        end

      end

      it "should mark input as checked if it's the the existing choice" do
        expect(::Post.all.include?(@fred.posts.first)).to be_truthy
        expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@checked='checked']")
      end
    end

    describe 'and no object is given' do
      before(:example) do
        @output_buffer = ActionView::OutputBuffer.new ''
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => ::Author.all))
        end)
      end

      it 'should generate a fieldset with legend' do
        expect(output_buffer.to_str).to have_tag('form li fieldset legend', :text => /Author/)
      end

      it 'shold generate an li tag for each item in the collection' do
        expect(output_buffer.to_str).to have_tag('form li fieldset ol li input[@type=checkbox]', :count => ::Author.all.size)
      end

      it 'should generate labels for each item' do
        ::Author.all.each do |author|
          expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', :text => /#{author.to_label}/)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='project_author_id_#{author.id}']")
        end
      end

      it 'should generate inputs for each item' do
        ::Author.all.each do |author|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input#project_author_id_#{author.id}")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@type='checkbox']")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@name='project[author_id][]']")
        end
      end

      it 'should html escape the label string' do
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => [["<b>Item 1</b>", 1], ["<b>Item 2</b>", 2]]))
        end)

        expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', text: %r{<b>Item [12]</b>}, count: 2) do |label|
          expect(label).to have_text('<b>Item 1</b>', count: 1)
          expect(label).to have_text('<b>Item 2</b>', count: 1)
        end
      end
    end

    describe 'when :hidden_fields is set to false' do
      before do
        @output_buffer = ActionView::OutputBuffer.new ''
        mock_everything

        concat(semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :value_as_class => true, :hidden_fields => false))
        end)
      end

      it 'should have a checkbox input for each post' do
        ::Post.all.each do |post|
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => ::Post.all.length)
        end
      end

      it "should mark input as checked if it's the the existing choice" do
        expect(::Post.all.include?(@fred.posts.first)).to be_truthy
        expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@checked='checked']")
      end

      it 'should not generate empty hidden inputs' do
        expect(output_buffer.to_str).not_to have_tag("form li fieldset ol li label input[@type='hidden'][@value='']", :count => ::Post.all.length)
      end
    end

    describe 'when :disabled is set' do
      before do
        @output_buffer = ActionView::OutputBuffer.new ''
      end

      describe "no disabled items" do
        before do
          allow(@new_post).to receive(:author_ids).and_return(nil)

          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :disabled => nil))
          end)
        end

        it 'should not have any disabled item(s)' do
          expect(output_buffer.to_str).not_to have_tag("form li fieldset ol li label input[@disabled='disabled']")
        end
      end

      describe "single disabled item" do
        before do
          allow(@new_post).to receive(:author_ids).and_return(nil)

          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :disabled => @fred.id))
          end)
        end

        it "should have one item disabled; the specified one" do
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@disabled='disabled']", :count => 1)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='post_author_ids_#{@fred.id}']", :text => /fred/i)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@disabled='disabled'][@value='#{@fred.id}']")
        end
      end

      describe "multiple disabled items" do
        before do
          allow(@new_post).to receive(:author_ids).and_return(nil)

          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :disabled => [@bob.id, @fred.id]))
          end)
        end

        it "should have multiple items disabled; the specified ones" do
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@disabled='disabled']", :count => 2)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='post_author_ids_#{@bob.id}']", :text => /bob/i)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@disabled='disabled'][@value='#{@bob.id}']")
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='post_author_ids_#{@fred.id}']", :text => /fred/i)
          expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@disabled='disabled'][@value='#{@fred.id}']")
        end
      end

    end

    describe "with i18n of the legend label" do

      before do
        ::I18n.backend.store_translations :en, :formtastic => { :labels => { :post => { :authors => "Translated!" }}}
        with_config :i18n_lookups_by_default, true do
          allow(@new_post).to receive(:author_ids).and_return(nil)
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes))
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
          concat(builder.input(:authors, :as => :check_boxes, :label => 'The authors'))
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
          concat(builder.input(:authors, :as => :check_boxes, :label => false))
        end)
      end

      it "should not output the legend" do
        expect(output_buffer.to_str).not_to have_tag("legend.label")
      end

      it "should not cause escaped HTML" do
        expect(output_buffer.to_str).not_to include("&gt;")
      end

    end

    describe "when :required option is true" do
      before do
        allow(@new_post).to receive(:author_ids).and_return(nil)
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:authors, :as => :check_boxes, :required => true))
        end)
      end

      it "should output the correct label title" do
        expect(output_buffer.to_str).to have_tag("legend.label label abbr")
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

    it 'should have a select inside the wrapper' do
      expect {
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:status, :as => :check_boxes))
        end)
      }.to raise_error(Formtastic::UnsupportedEnumCollection)
    end
  end

  describe 'for a has_and_belongs_to_many association' do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@freds_post) do |builder|
        concat(builder.input(:authors, :as => :check_boxes))
      end)
    end

    it 'should render checkboxes' do
      # I'm aware these two lines test the same thing
      expect(output_buffer.to_str).to have_tag('input[type="checkbox"]', :count => 2)
      expect(output_buffer.to_str).to have_tag('input[type="checkbox"]', :count => ::Author.all.size)
    end

    it 'should only select checkboxes that are present in the association' do
      # I'm aware these two lines test the same thing
      expect(output_buffer.to_str).to have_tag('input[checked="checked"]', :count => 1)
      expect(output_buffer.to_str).to have_tag('input[checked="checked"]', :count => @freds_post.authors.size)
    end

  end

  describe ':collection for a has_and_belongs_to_many association' do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@freds_post) do |builder|
        concat(builder.input(:authors, as: :check_boxes, collection: Author.all))
      end)
    end

    it 'should render checkboxes' do
      # I'm aware these two lines test the same thing
      expect(output_buffer.to_str).to have_tag('input[type="checkbox"]', :count => 2)
      expect(output_buffer.to_str).to have_tag('input[type="checkbox"]', :count => ::Author.all.size)
    end

    it 'should only select checkboxes that are present in the association' do
      # I'm aware these two lines test the same thing
      expect(output_buffer.to_str).to have_tag('input[checked="checked"]', :count => 1)
      expect(output_buffer.to_str).to have_tag('input[checked="checked"]', :count => @freds_post.authors.size)
    end

  end

  describe 'for an association when a :collection is provided' do
    describe 'it should use the specified :member_value option' do
      before do
        @output_buffer = ActionView::OutputBuffer.new ''
        mock_everything
      end

      it 'to set the right input value' do
        item = double('item')
        expect(item).not_to receive(:id)
        allow(item).to receive(:custom_value).and_return('custom_value')
        expect(item).to receive(:custom_value).exactly(3).times
        expect(@new_post.author).to receive(:custom_value).exactly(1).times

        with_deprecation_silenced do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:author, :as => :check_boxes, :member_value => :custom_value, :collection => [item, item, item]))
          end)
        end
        expect(output_buffer.to_str).to have_tag('input[@type=checkbox][@value="custom_value"]', :count => 3)
      end
    end
  end

  describe 'when :collection is provided as an array of arrays' do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything
      allow(@fred).to receive(:genres) { ['fiction', 'biography'] }

      concat(semantic_form_for(@fred) do |builder|
        concat(builder.input(:genres, :as => :check_boxes, :collection => [['Fiction', 'fiction'], ['Non-fiction', 'non_fiction'], ['Biography', 'biography']]))
      end)
    end

    it 'should check the correct checkboxes' do
      expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='fiction'][@checked='checked']")
      expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='biography'][@checked='checked']")
    end
  end

  describe 'when :collection is a set' do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything
      allow(@fred).to receive(:roles) { Set.new([:reviewer, :admin]) }

      concat(semantic_form_for(@fred) do |builder|
        concat(builder.input(:roles, :as => :check_boxes, :collection => [['User', :user], ['Reviewer', :reviewer], ['Administrator', :admin]]))
      end)
    end

    it 'should check the correct checkboxes' do
      expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='user']")
      expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='admin'][@checked='checked']")
      expect(output_buffer.to_str).to have_tag("form li fieldset ol li label input[@value='reviewer'][@checked='checked']")
    end
  end

  describe "when namespace is provided" do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@fred, :namespace => "context2") do |builder|
        concat(builder.input(:posts, :as => :check_boxes))
      end)
    end

    it "should have a label for #context2_author_post_ids_19" do
      expect(output_buffer.to_str).to have_tag("form li label[@for='context2_author_post_ids_19']")
    end

    it_should_have_input_with_id('context2_author_post_ids_19')
    it_should_have_input_wrapper_with_id("context2_author_posts_input")
  end

  describe "when index is provided" do

    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      mock_everything

      concat(semantic_form_for(@fred) do |builder|
        concat(builder.fields_for(@fred.posts.first, :index => 3) do |author|
          concat(author.input(:authors, :as => :check_boxes))
        end)
      end)
    end

    it 'should index the id of the wrapper' do
      expect(output_buffer.to_str).to have_tag("li#author_post_3_authors_input")
    end

    it 'should index the id of the input tag' do
      expect(output_buffer.to_str).to have_tag("input#author_post_3_author_ids_42")
    end

    it 'should index the name of the checkbox input' do
      expect(output_buffer.to_str).to have_tag("input[@type='checkbox'][@name='author[post][3][author_ids][]']")
    end

  end


  describe "when collection is an array" do
    before do
      @output_buffer = ActionView::OutputBuffer.new ''
      @_collection = [["First", 1], ["Second", 2]]
      mock_everything

      concat(semantic_form_for(@fred) do |builder|
        concat(builder.input(:posts, :as => :check_boxes, :collection => @_collection))
      end)
    end

    it "should use array items for labels and values" do
      @_collection.each do |post|
        expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', :text => /#{post.first}/)
        expect(output_buffer.to_str).to have_tag("form li fieldset ol li label[@for='author_post_ids_#{post.last}']")
      end
    end

    it "should not check any items" do
      expect(output_buffer.to_str).to have_tag('form li input[@checked]', :count => 0)
    end

    describe "and the attribute has values" do
      before do
        allow(@fred).to receive(:posts) { [1] }

        concat(semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :collection => @_collection))
        end)
      end

      it "should check the appropriate items" do
        expect(output_buffer.to_str).to have_tag("form li input[@value='1'][@checked]")
      end
    end

    describe "and the collection includes html options" do
      before do
        @_collection = [["First", 1, {'data-test' => 'test-data'}], ["Second", 2, {'data-test2' => 'test-data2'}]]

        concat(semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :collection => @_collection))
        end)
      end

      it "should have injected the html attributes" do
        @_collection.each do |v|
          expect(output_buffer.to_str).to have_tag("form li input[@value='#{v[1]}'][@#{v[2].keys[0]}='#{v[2].values[0]}']")
        end
      end
    end
  end

end

