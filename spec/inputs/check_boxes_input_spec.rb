# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'check_boxes input' do
  
  include FormtasticSpecHelper
  
  describe 'for a has_many association' do
    before do
      @output_buffer = ''
      mock_everything
      
      semantic_form_for(@fred) do |builder|
        concat(builder.input(:posts, :as => :check_boxes, :value_as_class => true))
      end
    end
    
    it_should_have_input_wrapper_with_class("check_boxes")
    it_should_have_input_wrapper_with_id("author_posts_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:check_boxes)
    it_should_call_find_on_association_class_when_no_collection_is_provided(:check_boxes)
    it_should_use_the_collection_when_provided(:check_boxes, 'input[@type="checkbox"]')
    
    it 'should generate a legend - classified as a label - containing label text for the input' do
      output_buffer.should have_tag('form li fieldset legend.label')
      output_buffer.should have_tag('form li fieldset legend.label', /Posts/)
    end

    it 'should generate an ordered list with a list item for each choice' do
      output_buffer.should have_tag('form li fieldset ol')
      output_buffer.should have_tag('form li fieldset ol li', :count => ::Post.find(:all).size)
    end

    it 'should have one option with a "checked" attribute' do
      output_buffer.should have_tag('form li input[@checked]', :count => 1)
    end

    it 'should generate hidden inputs with default value blank' do
      output_buffer.should have_tag("form li fieldset ol li label input[@type='hidden'][@value='']", :count => ::Post.find(:all).size)
    end

    describe "each choice" do

      it 'should contain a label for the radio input with a nested input and label text' do
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag('form li fieldset ol li label', /#{post.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='author_post_ids_#{post.id}']")
        end
      end

      it 'should use values as li.class when value_as_class is true' do
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li.#{post.id} label")
        end
      end

      it 'should have a checkbox input for each post' do
        ::Post.find(:all).each do |post|
          output_buffer.should have_tag("form li fieldset ol li label input#author_post_ids_#{post.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='author[post_ids][]']", :count => 2)
        end
      end

      it "should mark input as checked if it's the the existing choice" do
        ::Post.find(:all).include?(@fred.posts.first).should be_true
        output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
      end
    end

    describe 'and no object is given' do
      before(:each) do
        output_buffer.replace ''
        semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => ::Author.find(:all)))
        end
      end

      it 'should generate a fieldset with legend' do
        output_buffer.should have_tag('form li fieldset legend', /Author/)
      end

      it 'shold generate an li tag for each item in the collection' do
        output_buffer.should have_tag('form li fieldset ol li', :count => ::Author.find(:all).size)
      end

      it 'should generate labels for each item' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
          output_buffer.should have_tag("form li fieldset ol li label[@for='project_author_id_#{author.id}']")
        end
      end

      it 'should generate inputs for each item' do
        ::Author.find(:all).each do |author|
          output_buffer.should have_tag("form li fieldset ol li label input#project_author_id_#{author.id}")
          output_buffer.should have_tag("form li fieldset ol li label input[@type='checkbox']")
          output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
          output_buffer.should have_tag("form li fieldset ol li label input[@name='project[author_id][]']")
        end
      end
    end
  end

end

