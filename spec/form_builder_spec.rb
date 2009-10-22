# coding: utf-8
require File.dirname(__FILE__) + '/test_helper'

describe 'SemanticFormBuilder' do

  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'Formtastic::SemanticFormBuilder#semantic_fields_for' do
    before do
      @new_post.stub!(:author).and_return(::Author.new)
    end

    it 'yields an instance of SemanticFormHelper.builder' do  
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(:author) do |nested_builder|
          nested_builder.class.should == Formtastic::SemanticFormHelper.builder
        end
      end
    end

    it 'nests the object name' do
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(@bob) do |nested_builder|
          nested_builder.object_name.should == 'post[author]'
        end
      end
    end

    it 'should sanitize html id for li tag' do
      @bob.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(@bob, :index => 1) do |nested_builder|
          concat(nested_builder.inputs(:login))
        end
      end
      output_buffer.should have_tag('form fieldset.inputs #post_author_1_login_input')
      output_buffer.should_not have_tag('form fieldset.inputs #post[author]_1_login_input')
    end
  end

  describe '#label' do
    it 'should humanize the given attribute' do
      semantic_form_for(@new_post) do |builder|
        builder.label(:login).should have_tag('label', :with => /Login/)
      end
    end

    it 'should be printed as span' do
      semantic_form_for(@new_post) do |builder|
        builder.label(:login, nil, { :required => true, :as_span => true }).should have_tag('span.label abbr')
      end
    end

    describe 'when required is given' do
      it 'should append a required note' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, nil, :required => true).should have_tag('label abbr')
        end
      end

      it 'should allow require option to be given as second argument' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, :required => true).should have_tag('label abbr')
        end
      end
    end

    describe 'when label is given' do
      it 'should allow the text to be given as label option' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, :required => true, :label => 'My label').should have_tag('label', :with => /My label/)
        end
      end

      it 'should return nil if label is false' do
        semantic_form_for(@new_post) do |builder|
          builder.label(:login, :label => false).should be_blank
        end
      end
    end
  end

  describe '#commit_button' do

    describe 'when used on any record' do

      before do
        @new_post.stub!(:new_record?).and_return(false)
        semantic_form_for(@new_post) do |builder|
          concat(builder.commit_button)
        end
      end

      it 'should render a commit li' do
        output_buffer.should have_tag('li.commit')
      end

      it 'should render an input with a type attribute of "submit"' do
        output_buffer.should have_tag('li.commit input[@type="submit"]')
      end

      it 'should render an input with a name attribute of "commit"' do
        output_buffer.should have_tag('li.commit input[@name="commit"]')
      end

      it 'should pass options given in :button_html to the button' do
        @new_post.stub!(:new_record?).and_return(false)
        semantic_form_for(@new_post) do |builder|
          concat(builder.commit_button('text', :button_html => {:class => 'my_class', :id => 'my_id'}))
        end

        output_buffer.should have_tag('li.commit input#my_id')
        output_buffer.should have_tag('li.commit input.my_class')
      end
      
    end

    describe 'when the first option is a string and the second is a hash' do
      
      before do
        @new_post.stub!(:new_record?).and_return(false)
        semantic_form_for(@new_post) do |builder|
          concat(builder.commit_button("a string", :button_html => { :class => "pretty"}))
        end
      end
      
      it "should render the string as the value of the button" do
        output_buffer.should have_tag('li input[@value="a string"]')
      end
      
      it "should deal with the options hash" do
        output_buffer.should have_tag('li input.pretty')
      end
      
    end

    describe 'when the first option is a hash' do
      
      before do
        @new_post.stub!(:new_record?).and_return(false)
        semantic_form_for(@new_post) do |builder|
          concat(builder.commit_button(:button_html => { :class => "pretty"}))
        end
      end
      
      it "should deal with the options hash" do
        output_buffer.should have_tag('li input.pretty')
      end
      
    end

    describe 'when used on an existing record' do

      it 'should render an input with a value attribute of "Save Post"' do
        @new_post.stub!(:new_record?).and_return(false)
        semantic_form_for(@new_post) do |builder|
          concat(builder.commit_button)
        end
        output_buffer.should have_tag('li.commit input[@value="Save Post"]')
      end

      describe 'when the locale sets the label text' do
        before do
          I18n.backend.store_translations 'en', :formtastic => {:save => 'Save Changes To {{model}}' }
          @new_post.stub!(:new_record?).and_return(false)
          semantic_form_for(@new_post) do |builder|
            concat(builder.commit_button)
          end
        end

        after do
          I18n.backend.store_translations 'en', :formtastic => {:save => nil}
        end

        it 'should allow translation of the labels' do
          output_buffer.should have_tag('li.commit input[@value="Save Changes To Post"]')
        end
      end

      describe 'when the label text is set for a locale with different word order from the default' do
        before do
          I18n.locale = 'ja'
          I18n.backend.store_translations 'ja', :formtastic => {:save => 'Save {{model}}'}
          @new_post.stub!(:new_record?).and_return(false)
          ::Post.stub!(:human_name).and_return('Post')
          semantic_form_for(@new_post) do |builder|
            concat(builder.commit_button)
          end
        end

        after do
          I18n.backend.store_translations 'ja', :formtastic => {:save => nil}
          I18n.locale = 'en'
        end

        it 'should allow the translated label to have a different word order' do
          output_buffer.should have_tag('li.commit input[@value="Save Post"]')
        end
      end
    end

    describe 'when used on a new record' do

      it 'should render an input with a value attribute of "Create Post"' do
        @new_post.stub!(:new_record?).and_return(true)
        semantic_form_for(@new_post) do |builder|
          concat(builder.commit_button)
        end
        output_buffer.should have_tag('li.commit input[@value="Create Post"]')
      end

      describe 'when the locale sets the label text' do
        before do
          I18n.backend.store_translations 'en', :formtastic => {:create => 'Make {{model}}' }
          semantic_form_for(@new_post) do |builder|
            concat(builder.commit_button)
          end
        end

        after do
          I18n.backend.store_translations 'en', :formtastic => {:create => nil}
        end

        it 'should allow translation of the labels' do
          output_buffer.should have_tag('li.commit input[@value="Make Post"]')
        end
      end

    end

    describe 'when used without object' do

      it 'should render an input with a value attribute of "Submit"' do
        semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.commit_button)
        end

        output_buffer.should have_tag('li.commit input[@value="Submit Project"]')
      end

      describe 'when the locale sets the label text' do
        before do
          I18n.backend.store_translations 'en', :formtastic => { :submit => 'Send {{model}}' }
          semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.commit_button)
          end
        end

        after do
          I18n.backend.store_translations 'en', :formtastic => {:submit => nil}
        end

        it 'should allow translation of the labels' do
          output_buffer.should have_tag('li.commit input[@value="Send Project"]')
        end
      end

    end

  end

end

