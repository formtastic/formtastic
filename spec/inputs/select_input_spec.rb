# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'select input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'explicit values' do
    describe 'using an array of values' do
      before do
        @array_with_values = ["Title A", "Title B", "Title C"]
        @array_with_keys_and_values = [["Title D", 1], ["Title E", 2], ["Title F", 3]]
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :select, :collection => @array_with_values))
          concat(builder.input(:title, :as => :select, :collection => @array_with_keys_and_values))
        end
      end

      it 'should have a option for each key and/or value' do
        @array_with_values.each do |v|
          output_buffer.should have_tag("form li select option[@value='#{v}']", /^#{v}$/)
        end
        @array_with_keys_and_values.each do |v|
          output_buffer.should have_tag("form li select option[@value='#{v.second}']", /^#{v.first}$/)
        end
      end
    end

    describe 'using a range' do
      before do
        @range_with_values = 1..5
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :as => :select, :collection => @range_with_values))
        end
      end

      it 'should have an option for each value' do
        @range_with_values.each do |v|
          output_buffer.should have_tag("form li select option[@value='#{v}']", /^#{v}$/)
        end
      end
    end
  end

  describe 'for a belongs_to association' do
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :select))
      end
    end
    
    it_should_have_input_wrapper_with_class("select")
    it_should_have_input_wrapper_with_id("post_author_input")
    it_should_have_label_with_text(/Author/)
    it_should_have_label_for('post_author_id')
    it_should_apply_error_logic_for_input_type(:select)
    it_should_call_find_on_association_class_when_no_collection_is_provided(:select)
    it_should_use_the_collection_when_provided(:select, 'option')
    
    it 'should have a select inside the wrapper' do
      output_buffer.should have_tag('form li select')
      output_buffer.should have_tag('form li select#post_author_id')
    end

    it 'should not create a multi-select' do
      output_buffer.should_not have_tag('form li select[@multiple]')
    end

    it 'should create a select without size' do
      output_buffer.should_not have_tag('form li select[@size]')
    end

    it 'should have a blank option' do
      output_buffer.should have_tag("form li select option[@value='']")
    end

    it 'should have a select option for each Author' do
      output_buffer.should have_tag('form li select option', :count => ::Author.find(:all).size + 1)
      ::Author.find(:all).each do |author|
        output_buffer.should have_tag("form li select option[@value='#{author.id}']", /#{author.to_label}/)
      end
    end

    it 'should have one option with a "selected" attribute' do
      output_buffer.should have_tag('form li select option[@selected]', :count => 1)
    end

    it 'should not singularize the association name' do
      @new_post.stub!(:author_status).and_return(@bob)
      @new_post.stub!(:author_status_id).and_return(@bob.id)
      @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :integer, :limit => 255))

      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author_status, :as => :select))
      end

      output_buffer.should have_tag('form li select#post_author_status_id')
    end
  end
  
  describe 'for a belongs_to association with :group_by => :continent' do
    before do
      @authors = [@bob, @fred, @fred, @fred]
      ::Author.stub!(:find).and_return(@authors)
      @continent_names = %w(Europe Africa)
      @continents = (0..1).map { |i| mock("continent", :id => (100 - i) ) }
      @authors[0..1].each_with_index { |author, i| author.stub!(:continent).and_return(@continents[i]) }
      @continents.each_with_index do |continent, i| 
        continent.stub!(:to_label).and_return(@continent_names[i])
        continent.stub!(:authors).and_return([@authors[i]])
      end
      
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :select, :group_by => :continent ) )
        concat(builder.input(:author, :as => :select, :group_by => :continent, :group_label_method => :id ) )
      end
    end

    it_should_have_input_wrapper_with_class("select")
    it_should_have_input_wrapper_with_id("post_author_input")
    it_should_have_label_with_text(/Author/)
    it_should_have_label_for('post_author_id')
    
    # TODO, need to find a way to repeat some of the specs and logic from the belongs_to specs without grouping

    0.upto(1) do |i|
      it 'should have all option groups and the right values' do
        output_buffer.should have_tag("form li select optgroup[@label='#{@continent_names[i]}']", @authors[i].to_label)
      end

      it 'should have custom group labels' do
        output_buffer.should have_tag("form li select optgroup[@label='#{@continents[i].id}']", @authors[i].to_label)
      end
    end

    it 'should have no duplicate groups' do
      output_buffer.should have_tag('form li select optgroup', :count => 4)
    end
    
    it 'should sort the groups on the label method' do
      output_buffer.should have_tag("form li select optgroup[@label='Africa']")
      output_buffer.should have_tag("form li select optgroup[@label='99']")
    end
    
    it 'should call find with :include for more optimized queries' do
      Author.should_receive(:find).with(:all, :include => :continent)

      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :select, :group_by => :continent ) )
      end
    end
  end

  describe 'for a has_many association' do
    before do
      semantic_form_for(@fred) do |builder|
        concat(builder.input(:posts, :as => :select))
      end
    end

    it_should_have_input_wrapper_with_class("select")
    it_should_have_input_wrapper_with_id("author_posts_input")
    it_should_have_label_with_text(/Post/)
    it_should_have_label_for('author_post_ids')
    it_should_apply_error_logic_for_input_type(:select)
    it_should_call_find_on_association_class_when_no_collection_is_provided(:select)
    it_should_use_the_collection_when_provided(:select, 'option')

    it 'should have a select inside the wrapper' do
      output_buffer.should have_tag('form li select')
      output_buffer.should have_tag('form li select#author_post_ids')
    end

    it 'should have a multi-select select' do
      output_buffer.should have_tag('form li select[@multiple="multiple"]')
    end

    it 'should have a select option for each Post' do
      output_buffer.should have_tag('form li select option', :count => ::Post.find(:all).size)
      ::Post.find(:all).each do |post|
        output_buffer.should have_tag("form li select option[@value='#{post.id}']", /#{post.to_label}/)
      end
    end
    
    it 'should not have a blank option' do
      output_buffer.should_not have_tag("form li select option[@value='']")
    end

    it 'should have one option with a "selected" attribute' do
      output_buffer.should have_tag('form li select option[@selected]', :count => 1)
    end
  end

  describe 'for a has_and_belongs_to_many association' do
    before do
      semantic_form_for(@freds_post) do |builder|
        concat(builder.input(:authors, :as => :select))
      end
    end
    
    it_should_have_input_wrapper_with_class("select")
    it_should_have_input_wrapper_with_id("post_authors_input")
    it_should_have_label_with_text(/Author/)
    it_should_have_label_for('post_author_ids')
    it_should_apply_error_logic_for_input_type(:select)
    it_should_call_find_on_association_class_when_no_collection_is_provided(:select)
    it_should_use_the_collection_when_provided(:select, 'option')
    
    it 'should have a select inside the wrapper' do
      output_buffer.should have_tag('form li select')
      output_buffer.should have_tag('form li select#post_author_ids')
    end

    it 'should have a multi-select select' do
      output_buffer.should have_tag('form li select[@multiple="multiple"]')
    end

    it 'should have a select option for each Author' do
      output_buffer.should have_tag('form li select option', :count => ::Author.find(:all).size)
      ::Author.find(:all).each do |author|
        output_buffer.should have_tag("form li select option[@value='#{author.id}']", /#{author.to_label}/)
      end
    end
    
    it 'should not have a blank option' do
      output_buffer.should_not have_tag("form li select option[@value='']")
    end

    it 'should have one option with a "selected" attribute' do
      output_buffer.should have_tag('form li select option[@selected]', :count => 1)
    end
  end

  describe 'when :prompt => "choose something" is set' do
    before do
      @new_post.stub!(:author_id).and_return(nil)
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :select, :prompt => "choose author"))
      end
    end

    it 'should have a select with prompt' do
      output_buffer.should have_tag("form li select option[@value='']", /choose author/)
    end

    it 'should not have a blank select option' do
      output_buffer.should_not have_tag("form li select option[@value='']", "")
    end
  end

  describe 'when no object is given' do
    before(:each) do
      semantic_form_for(:project, :url => 'http://test.host') do |builder|
        concat(builder.input(:author, :as => :select, :collection => ::Author.find(:all)))
      end
    end

    it 'should generate label' do
      output_buffer.should have_tag('form li label', /Author/)
      output_buffer.should have_tag("form li label[@for='project_author']")
    end

    it 'should generate select inputs' do
      output_buffer.should have_tag('form li select#project_author')
      output_buffer.should have_tag('form li select option', :count => ::Author.find(:all).size + 1)
    end

    it 'should generate an option to each item' do
      ::Author.find(:all).each do |author|
        output_buffer.should have_tag("form li select option[@value='#{author.id}']", /#{author.to_label}/)
      end
    end
  end

  describe 'when :selected is set' do
    before do
      @new_post.stub!(:author_id).and_return(nil)
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:author, :as => :select, :selected => @bob.id ))
      end
    end
     
    it 'should have a selected item' do
      output_buffer.should have_tag("form li select option[@selected='selected']")
    end
    
    it 'bob should be selected' do
      output_buffer.should have_tag("form li select option[@selected='selected']", /bob/i)
      output_buffer.should have_tag("form li select option[@selected='selected'][@value='42']")
    end
    
  end

  describe 'boolean select' do
    describe 'default formtastic locale' do
      before do
        # Note: Works, but something like Formtastic.root.join(...) would probably be "safer".
        ::I18n.load_path = [File.join(File.dirname(__FILE__), *%w[.. .. lib locale en.yml])]
        ::I18n.backend.send(:init_translations)

        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:published, :as => :select))
        end
      end

      after do
        ::I18n.backend.store_translations :en, {}
      end

      it 'should render a select with at least options: true/false' do
        output_buffer.should have_tag("form li select option[@value='true']", /^Yes$/)
        output_buffer.should have_tag("form li select option[@value='false']", /^No$/)
      end
    end
    
    describe 'custom locale' do
      before do
        @boolean_select_labels = {:yes => 'Yep', :no => 'Nope'}
        ::I18n.backend.store_translations :en, :formtastic => @boolean_select_labels

        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:published, :as => :select))
        end
      end

      after do
        ::I18n.backend.store_translations :en, {}
      end

      it 'should render a select with at least options: true/false' do
        output_buffer.should have_tag("form li select option[@value='true']", /#{@boolean_select_labels[:yes]}/)
        output_buffer.should have_tag("form li select option[@value='false']", /#{@boolean_select_labels[:no]}/)
      end
    end
  end

end
