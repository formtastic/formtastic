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

  describe '#errors_on' do
    before(:each) do
      @title_errors = ['must not be blank', 'must be longer than 10 characters', 'must be awesome']
      @errors = mock('errors')
      @new_post.stub!(:errors).and_return(@errors)
    end
    
    describe "field error proc" do
      it "should not be overridden globally for all form builders" do
        current_field_error_proc = ::ActionView::Base.field_error_proc
        
        semantic_form_for(@new_post) do |builder|
          ::ActionView::Base.field_error_proc.should_not == current_field_error_proc
        end
        
        ::ActionView::Base.field_error_proc.should == current_field_error_proc
        
        form_for(@new_post) do |builder|
          ::ActionView::Base.field_error_proc.should == current_field_error_proc
        end
      end
    end
    
    describe 'when there are errors' do
      before do
        @errors.stub!(:[]).with(:title).and_return(@title_errors)
      end
      
      it 'should render a paragraph with the errors joined into a sentence when inline_errors config is :sentence' do
        Formtastic::SemanticFormBuilder.inline_errors = :sentence
        semantic_form_for(@new_post) do |builder|
          builder.errors_on(:title).should have_tag('p.inline-errors', @title_errors.to_sentence)
        end
      end
      
      it 'should render an unordered list with the class errors when inline_errors config is :list' do
        Formtastic::SemanticFormBuilder.inline_errors = :list
        semantic_form_for(@new_post) do |builder|
          builder.errors_on(:title).should have_tag('ul.errors')
          @title_errors.each do |error|
            builder.errors_on(:title).should have_tag('ul.errors li', error)
          end
        end
      end
      
      it 'should return nil when inline_errors config is :none' do
        Formtastic::SemanticFormBuilder.inline_errors = :none
        semantic_form_for(@new_post) do |builder|
          builder.errors_on(:title).should be_nil
        end
      end
      
    end
    
    describe 'when there are no errors (nil)' do
      before do
        @errors.stub!(:[]).with(:title).and_return(nil)
      end
      
      it 'should return nil when inline_errors config is :sentence, :list or :none' do
        [:sentence, :list, :none].each do |config|
          Formtastic::SemanticFormBuilder.inline_errors = config
          semantic_form_for(@new_post) do |builder|
            builder.errors_on(:title).should be_nil
          end
        end
      end
    end
    
    describe 'when there are no errors (empty array)' do
      before do
        @errors.stub!(:[]).with(:title).and_return([])
      end
      
      it 'should return nil when inline_errors config is :sentence, :list or :none' do
        [:sentence, :list, :none].each do |config|
          Formtastic::SemanticFormBuilder.inline_errors = config
          semantic_form_for(@new_post) do |builder|
            builder.errors_on(:title).should be_nil
          end
        end
      end
    end
    
  end
  
  describe '#buttons' do

    describe 'with a block' do
      describe 'when no options are provided' do
        before do
          semantic_form_for(@new_post) do |builder|
            builder.buttons do
              concat('hello')
            end
          end
        end

        it 'should render a fieldset inside the form, with a class of "inputs"' do
          output_buffer.should have_tag("form fieldset.buttons")
        end

        it 'should render an ol inside the fieldset' do
          output_buffer.should have_tag("form fieldset.buttons ol")
        end

        it 'should render the contents of the block inside the ol' do
          output_buffer.should have_tag("form fieldset.buttons ol", /hello/)
        end

        it 'should not render a legend inside the fieldset' do
          output_buffer.should_not have_tag("form fieldset.buttons legend")
        end
      end

      describe 'when a :name option is provided' do
        before do
          @legend_text = "Advanced options"

          semantic_form_for(@new_post) do |builder|
            builder.buttons :name => @legend_text do
            end
          end
        end
        it 'should render a fieldset inside the form' do
          output_buffer.should have_tag("form fieldset legend", /#{@legend_text}/)
        end
      end

      describe 'when other options are provided' do
        before do
          @id_option = 'advanced'
          @class_option = 'wide'

          semantic_form_for(@new_post) do |builder|
            builder.buttons :id => @id_option, :class => @class_option do
            end
          end
        end
        it 'should pass the options into the fieldset tag as attributes' do
          output_buffer.should have_tag("form fieldset##{@id_option}")
          output_buffer.should have_tag("form fieldset.#{@class_option}")
        end
      end

    end

    describe 'without a block' do

      describe 'with no args (default buttons)' do

        before do
          semantic_form_for(@new_post) do |builder|
            concat(builder.buttons)
          end
        end

        it 'should render a form' do
          output_buffer.should have_tag('form')
        end

        it 'should render a buttons fieldset inside the form' do
          output_buffer.should have_tag('form fieldset.buttons')
        end

        it 'should not render a legend in the fieldset' do
          output_buffer.should_not have_tag('form fieldset.buttons legend')
        end

        it 'should render an ol in the fieldset' do
          output_buffer.should have_tag('form fieldset.buttons ol')
        end

        it 'should render a list item in the ol for each default button' do
          output_buffer.should have_tag('form fieldset.buttons ol li', :count => 1)
        end

        it 'should render a commit list item for the commit button' do
          output_buffer.should have_tag('form fieldset.buttons ol li.commit')
        end

      end

      describe 'with button names as args' do

        before do
          semantic_form_for(@new_post) do |builder|
            concat(builder.buttons(:commit))
          end
        end

        it 'should render a form with a fieldset containing a list item for each button arg' do
          output_buffer.should have_tag('form > fieldset.buttons > ol > li', :count => 1)
          output_buffer.should have_tag('form > fieldset.buttons > ol > li.commit')
        end

      end

      describe 'with button names as args and an options hash' do

        before do
          semantic_form_for(@new_post) do |builder|
            concat(builder.buttons(:commit, :name => "Now click a button", :id => "my-id"))
          end
        end

        it 'should render a form with a fieldset containing a list item for each button arg' do
          output_buffer.should have_tag('form > fieldset.buttons > ol > li', :count => 1)
          output_buffer.should have_tag('form > fieldset.buttons > ol > li.commit', :count => 1)
        end

        it 'should pass the options down to the fieldset' do
          output_buffer.should have_tag('form > fieldset#my-id.buttons')
        end

        it 'should use the special :name option as a text for the legend tag' do
          output_buffer.should have_tag('form > fieldset#my-id.buttons > legend', /Now click a button/)
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

