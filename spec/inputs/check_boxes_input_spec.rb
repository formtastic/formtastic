# coding: utf-8
require 'spec_helper'

describe 'check_boxes input' do
  
  include FormtasticSpecHelper
  
  describe 'for a has_many association' do
    before do
      @output_buffer = ''
      mock_everything
      
      @form = semantic_form_for(@fred) do |builder|
        concat(builder.input(:posts, :as => :check_boxes, :value_as_class => true))
      end
    end
    
    it_should_have_input_wrapper_with_class("check_boxes")
    it_should_have_input_wrapper_with_id("author_posts_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:check_boxes)
    it_should_call_find_on_association_class_when_no_collection_is_provided(:check_boxes)
    it_should_use_the_collection_when_provided(:check_boxes, 'input[@type="checkbox"]')
    
    it 'should generate a legend containing a label with text for the input' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag('form li fieldset legend.label label')
      output_buffer.should have_tag('form li fieldset legend.label label', /Posts/)
    end
    
    it 'should not link the label within the legend to any input' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should_not have_tag('form li fieldset legend label[@for^="author_post_ids_"]')
    end
    

    it 'should generate an ordered list with a list item for each choice' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag('form li fieldset ol')
      output_buffer.should have_tag('form li fieldset ol li input[@type=checkbox]', :count => ::Post.find(:all).size)
    end

    it 'should have one option with a "checked" attribute' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should have_tag('form li input[@checked]', :count => 1)
    end

    it 'should not generate hidden inputs with default value blank' do
      output_buffer.concat(@form) if Formtastic::Util.rails3?
      output_buffer.should_not have_tag("form li fieldset ol li label input[@type='hidden'][@value='']", :count => ::Post.find(:all).size)
    end

    describe "each choice" do

      it 'should contain a label for the radio input with a nested input and label text' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag('form li fieldset ol li label', /#{post.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='author_post_ids_#{post.id}']")
        end
      end

      it 'should use values as li.class when value_as_class is true' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li.post_#{post.id} label")
        end
      end

      it 'should have a checkbox input but no hidden field for each post' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => 1)
        end
      end

      it 'should have a hidden field with an empty array value for the collection to allow clearing of all checkboxes' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag("form li fieldset > input[@type=hidden][@name='author[post_ids][]'][@value='']", :count => 1)
      end

      it 'the hidden field with an empty array value should be followed by the ol' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag("form li fieldset > input[@type=hidden][@name='author[post_ids][]'][@value=''] + ol", :count => 1)
      end

      it 'should not have a hidden field with an empty string value for the collection' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should_not have_tag("form li fieldset > input[@type=hidden][@name='author[post_ids]'][@value='']", :count => 1)
      end

      it 'should have a checkbox and a hidden field for each post with :hidden_field => true' do
        output_buffer.replace ''

        form = semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :hidden_fields => true, :value_as_class => true))
        end
        output_buffer.concat(form) if Formtastic::Util.rails3?

        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => 2)
        end

      end

      it "should mark input as checked if it's the the existing choice" do
        ::Post.find(:all).include?(@fred.posts.first).should be_true
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
      end
    end

    describe 'and no object is given' do
      before(:each) do
        output_buffer.replace ''
        @form = semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => ::Author.find(:all)))
        end
      end

      it 'should generate a fieldset with legend' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('form li fieldset legend', /Author/)
      end

      it 'shold generate an li tag for each item in the collection' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('form li fieldset ol li input[@type=checkbox]', :count => ::Author.find(:all).size)
      end

      it 'should generate labels for each item' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='project_author_id_#{author.id}']")
        end
      end

      it 'should generate inputs for each item' do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag("form li fieldset ol li label input#project_author_id_#{author.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@type='checkbox']")
          output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='project[author_id][]']")
        end
      end

      it 'should html escape the label string' do
        form = semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => [["<b>Item 1</b>", 1], ["<b>Item 2</b>", 2]]))
        end
        output_buffer.concat(form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('form li fieldset ol li label') do |label|
          label.body.should match /&lt;b&gt;Item [12]&lt;\/b&gt;$/
        end
      end
    end

    describe 'when :hidden_fields is set to false' do
      before do
        @output_buffer = ''
        mock_everything

        form = semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :value_as_class => true, :hidden_fields => false))
        end
        output_buffer.concat(form) if Formtastic::Util.rails3?        
      end

      it 'should have a checkbox input for each post' do
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => ::Post.find(:all).length)
        end
      end

      it "should mark input as checked if it's the the existing choice" do
        ::Post.find(:all).include?(@fred.posts.first).should be_true
        output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
      end

      it 'should not generate empty hidden inputs' do
        output_buffer.should_not have_tag("form li fieldset ol li label input[@type='hidden'][@value='']", :count => ::Post.find(:all).length)
      end
    end

    describe 'when :selected is set' do
      before do
        @output_buffer = ''
      end

      describe "no selected items" do
        before do
          @new_post.stub!(:author_ids).and_return(nil)

          with_deprecation_silenced do
            @form = semantic_form_for(@new_post) do |builder|
              concat(builder.input(:authors, :as => :check_boxes, :selected => nil))
            end
          end
        end

        it 'should not have any selected item(s)' do
          output_buffer.concat(@form) if Formtastic::Util.rails3?
          output_buffer.should_not have_tag("form li fieldset ol li label input[@checked='checked']")
        end
      end

      describe "single selected item" do
        before do
          @new_post.stub!(:author_ids).and_return(nil)

          with_deprecation_silenced do
            @form = semantic_form_for(@new_post) do |builder|
              concat(builder.input(:authors, :as => :check_boxes, :selected => @fred.id))
            end
          end
        end

        it "should have one item selected; the specified one" do
          output_buffer.concat(@form) if Formtastic::Util.rails3?
          output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']", :count => 1)
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_ids_#{@fred.id}']", /fred/i)
          output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked'][@value='#{@fred.id}']")
        end
      end

      describe "multiple selected items" do
        before do
          @new_post.stub!(:author_ids).and_return(nil)
          
          with_deprecation_silenced do
            @form = semantic_form_for(@new_post) do |builder|
              concat(builder.input(:authors, :as => :check_boxes, :selected => [@bob.id, @fred.id]))
            end
          end
        end

        it "should have multiple items selected; the specified ones" do
          output_buffer.concat(@form) if Formtastic::Util.rails3?
          output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']", :count => 2)
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_ids_#{@bob.id}']", /bob/i)
          output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked'][@value='#{@bob.id}']")
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_ids_#{@fred.id}']", /fred/i)
          output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked'][@value='#{@fred.id}']")
        end
      end

    end
    
    it 'should warn about :selected deprecation' do
      with_deprecation_silenced do
        ::ActiveSupport::Deprecation.should_receive(:warn).any_number_of_times
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:authors, :as => :check_boxes, :selected => @bob.id))
        end
      end
    end
    

    describe 'when :disabled is set' do
      before do
        @output_buffer = ''
      end

      describe "no disabled items" do
        before do
          @new_post.stub!(:author_ids).and_return(nil)

          @form = semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :disabled => nil))
          end
        end

        it 'should not have any disabled item(s)' do
          output_buffer.concat(@form) if Formtastic::Util.rails3?
          output_buffer.should_not have_tag("form li fieldset ol li label input[@disabled='disabled']")
        end
      end

      describe "single disabled item" do
        before do
          @new_post.stub!(:author_ids).and_return(nil)

          @form = semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :disabled => @fred.id))
          end
        end

        it "should have one item disabled; the specified one" do
          output_buffer.concat(@form) if Formtastic::Util.rails3?
          output_buffer.should have_tag("form li fieldset ol li label input[@disabled='disabled']", :count => 1)
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_ids_#{@fred.id}']", /fred/i)
          output_buffer.should have_tag("form li fieldset ol li label input[@disabled='disabled'][@value='#{@fred.id}']")
        end
      end

      describe "multiple disabled items" do
        before do
          @new_post.stub!(:author_ids).and_return(nil)

          @form = semantic_form_for(@new_post) do |builder|
            concat(builder.input(:authors, :as => :check_boxes, :disabled => [@bob.id, @fred.id]))
          end
        end

        it "should have multiple items disabled; the specified ones" do
          output_buffer.concat(@form) if Formtastic::Util.rails3?
          output_buffer.should have_tag("form li fieldset ol li label input[@disabled='disabled']", :count => 2)
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_ids_#{@bob.id}']", /bob/i)
          output_buffer.should have_tag("form li fieldset ol li label input[@disabled='disabled'][@value='#{@bob.id}']")
          output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_ids_#{@fred.id}']", /fred/i)
          output_buffer.should have_tag("form li fieldset ol li label input[@disabled='disabled'][@value='#{@fred.id}']")
        end
      end

    end
    
    describe "with i18n of the legend label" do

      before do
        ::I18n.backend.store_translations :en, :formtastic => { :labels => { :post => { :authors => "Translated!" }}}
        Formtastic::SemanticFormBuilder.i18n_lookups_by_default = true

        @new_post.stub!(:author_ids).and_return(nil)
        @form = semantic_form_for(@new_post) do |builder|
          concat(builder.input(:authors, :as => :check_boxes))
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
          concat(builder.input(:authors, :as => :check_boxes, :label => 'The authors'))
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
          concat(builder.input(:authors, :as => :check_boxes, :label => false))
        end
      end

      it "should not output the legend" do
        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should_not have_tag("legend.label")
      end
    end
  end

  describe 'for a has_and_belongs_to_many association' do
    
    before do
      @output_buffer = ''
      mock_everything
      
      @form = semantic_form_for(@freds_post) do |builder|
        concat(builder.input(:authors, :as => :check_boxes))
      end
      output_buffer.concat(@form) if Formtastic::Util.rails3?
    end
    
    it 'should render checkboxes' do
      # I'm aware these two lines test the same thing
      output_buffer.should have_tag('input[type="checkbox"]', :count => 2)
      output_buffer.should have_tag('input[type="checkbox"]', :count => ::Author.find(:all).size)
    end
    
    it 'should only select checkboxes that are present in the association' do
      # I'm aware these two lines test the same thing
      output_buffer.should have_tag('input[checked="checked"]', :count => 1)
      output_buffer.should have_tag('input[checked="checked"]', :count => @freds_post.authors.size)
    end
    
  end

  describe 'for an association when a :collection is provided' do
    describe 'it should use the specified :value_method option' do
      before do
        @output_buffer = ''
        mock_everything
      end

      it 'to set the right input value' do
        item = mock('item')
        item.should_not_receive(:id)
        item.stub!(:custom_value).and_return('custom_value')
        item.should_receive(:custom_value).exactly(3).times
        @new_post.author.should_receive(:custom_value)
        @form = semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :check_boxes, :value_method => :custom_value, :collection => [item, item, item]))
        end

        output_buffer.concat(@form) if Formtastic::Util.rails3?
        output_buffer.should have_tag('input[@type=checkbox][@value="custom_value"]', :count => 3)
      end
    end
  end

end

