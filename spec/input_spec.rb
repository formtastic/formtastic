# coding: utf-8
require File.dirname(__FILE__) + '/test_helper'

describe 'SemanticFormBuilder#input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'with inline order customization' do
    it 'should allow input, hints, errors as order' do
      Formtastic::SemanticFormBuilder.inline_order = [:input, :hints, :errors]

      semantic_form_for(@new_post) do |builder|
        builder.should_receive(:inline_input_for).once.ordered
        builder.should_receive(:inline_hints_for).once.ordered
        builder.should_receive(:inline_errors_for).once.ordered
        concat(builder.input(:title))
      end
    end

    it 'should allow hints, input, errors as order' do
      Formtastic::SemanticFormBuilder.inline_order = [:hints, :input, :errors]

      semantic_form_for(@new_post) do |builder|
        builder.should_receive(:inline_hints_for).once.ordered
        builder.should_receive(:inline_input_for).once.ordered
        builder.should_receive(:inline_errors_for).once.ordered
        concat(builder.input(:title))
      end
    end
  end

  describe 'arguments and options' do

    it 'should require the first argument (the method on form\'s object)' do
      lambda {
        semantic_form_for(@new_post) do |builder|
          concat(builder.input()) # no args passed in at all
        end
      }.should raise_error(ArgumentError)
    end

    describe ':required option' do

      describe 'when true' do

        before do
          @string = Formtastic::SemanticFormBuilder.required_string = " required yo!" # ensure there's something in the string
          @new_post.class.should_not_receive(:reflect_on_all_validations)
        end

        after do
          Formtastic::SemanticFormBuilder.required_string = %{<abbr title="required">*</abbr>}
        end

        it 'should set a "required" class' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => true))
          end
          output_buffer.should_not have_tag('form li.optional')
          output_buffer.should have_tag('form li.required')
        end

        it 'should append the "required" string to the label' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => true))
          end
          output_buffer.should have_tag('form li.required label', /#{@string}$/)
        end

      end

      describe 'when false' do

        before do
          @string = Formtastic::SemanticFormBuilder.optional_string = " optional yo!" # ensure there's something in the string
          @new_post.class.should_not_receive(:reflect_on_all_validations)
        end

        after do
          Formtastic::SemanticFormBuilder.optional_string = ''
        end

        it 'should set an "optional" class' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end
          output_buffer.should_not have_tag('form li.required')
          output_buffer.should have_tag('form li.optional')
        end

        it 'should append the "optional" string to the label' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end
          output_buffer.should have_tag('form li.optional label', /#{@string}$/)
        end

      end

      describe 'when not provided' do

        describe 'and an object was not given' do

          it 'should use the default value' do
            Formtastic::SemanticFormBuilder.all_fields_required_by_default.should == true
            Formtastic::SemanticFormBuilder.all_fields_required_by_default = false

            semantic_form_for(:project, :url => 'http://test.host/') do |builder|
              concat(builder.input(:title))
            end
            output_buffer.should_not have_tag('form li.required')
            output_buffer.should have_tag('form li.optional')

            Formtastic::SemanticFormBuilder.all_fields_required_by_default = true
          end

        end

        describe 'and an object was given' do

          describe 'and the validation reflection plugin is available' do

            before do
              @new_post.class.stub!(:method_defined?).with(:reflect_on_validations_for).and_return(true)
            end

            describe 'and validates_presence_of was called for the method' do
              it 'should be required' do
                @new_post.class.should_receive(:reflect_on_validations_for).with(:title).and_return([
                  mock('MacroReflection', :macro => :validates_presence_of, :name => :title, :options => nil)
                ])
                @new_post.class.should_receive(:reflect_on_validations_for).with(:body).and_return([
                  mock('MacroReflection', :macro => :validates_presence_of, :name => :body, :options => {:if => true})
                ])

                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                  concat(builder.input(:body))
                end
                output_buffer.should have_tag('form li.required')
                output_buffer.should_not have_tag('form li.optional')
              end

              it 'should be not be required if the optional :if condition is not satisifed' do
                should_be_required(:required => false, :options => { :if => false })
              end
              
              it 'should not be required if the optional :if proc evaluates to false' do
                should_be_required(:required => false, :options => { :if => proc { |record| false } })
              end
              
              it 'should be required if the optional :if proc evaluates to true' do
                should_be_required(:required => true, :options => { :if => proc { |record| true } })
              end
              
              it 'should not be required if the optional :unless proc evaluates to true' do
                should_be_required(:required => false, :options => { :unless => proc { |record| true } })
              end
              
              it 'should be required if the optional :unless proc evaluates to false' do
                should_be_required(:required => true, :options => { :unless => proc { |record| false } })
              end
              
              it 'should be required if the optional :if with a method string evaluates to true' do
                @new_post.should_receive(:required_condition).and_return(true)
                should_be_required(:required => true, :options => { :if => :required_condition })
              end
              
              it 'should be required if the optional :if with a method string evaluates to false' do
                @new_post.should_receive(:required_condition).and_return(false)
                should_be_required(:required => false, :options => { :if => :required_condition })
              end
              
              it 'should not be required if the optional :unless with a method string evaluates to false' do
                 @new_post.should_receive(:required_condition).and_return(false)
                should_be_required(:required => true, :options => { :unless => :required_condition })
              end
              
               it 'should be required if the optional :unless with a method string evaluates to true' do
                 @new_post.should_receive(:required_condition).and_return(true)
                 should_be_required(:required => false, :options => { :unless => :required_condition })
               end
            end
            
            # TODO make a matcher for this?
            def should_be_required(options)
              @new_post.class.should_receive(:reflect_on_validations_for).with(:body).and_return([
                mock('MacroReflection', :macro => :validates_presence_of, :name => :body, :options => options[:options])
              ])
              
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:body))
              end
              
              if options[:required]
                output_buffer.should_not have_tag('form li.optional')
                output_buffer.should have_tag('form li.required')
              else
                output_buffer.should have_tag('form li.optional')
                output_buffer.should_not have_tag('form li.required')
              end
            end

            describe 'and validates_presence_of was not called for the method' do
              before do
                @new_post.class.should_receive(:reflect_on_validations_for).with(:title).and_return([])
              end

              it 'should not be required' do
                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end
                output_buffer.should_not have_tag('form li.required')
                output_buffer.should have_tag('form li.optional')
              end
            end

          end

          describe 'and the validation reflection plugin is not available' do

            it 'should use the default value' do
              Formtastic::SemanticFormBuilder.all_fields_required_by_default.should == true
              Formtastic::SemanticFormBuilder.all_fields_required_by_default = false

              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')

              Formtastic::SemanticFormBuilder.all_fields_required_by_default = true
            end

          end

        end

      end

    end

    describe ':as option' do

      describe 'when not provided' do

        it 'should default to a string for forms without objects unless column is password' do
          semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.input(:anything))
          end
          output_buffer.should have_tag('form li.string')
        end

        it 'should default to password for forms without objects if column is password' do
          semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.input(:password))
            concat(builder.input(:password_confirmation))
            concat(builder.input(:confirm_password))
          end
          output_buffer.should have_tag('form li.password', :count => 3)
        end

        it 'should default to a string for methods on objects that don\'t respond to "column_for_attribute"' do
          @new_post.stub!(:method_without_a_database_column)
          @new_post.stub!(:column_for_attribute).and_return(nil)
          default_input_type(nil, :method_without_a_database_column).should == :string
        end

        it 'should default to :password for methods that don\'t have a column in the database but "password" is in the method name' do
          @new_post.stub!(:password_method_without_a_database_column)
          @new_post.stub!(:column_for_attribute).and_return(nil)
          default_input_type(nil, :password_method_without_a_database_column).should == :password
        end

        it 'should default to :password for methods on objects that don\'t respond to "column_for_attribute" but "password" is in the method name' do
          @new_post.stub!(:password_method_without_a_database_column)
          @new_post.stub!(:column_for_attribute).and_return(nil)
          default_input_type(nil, :password_method_without_a_database_column).should == :password
        end

        it 'should default to :select for column names ending in "_id"' do
          default_input_type(:integer, :user_id).should == :select
          default_input_type(:integer, :section_id).should == :select
        end

        it 'should default to :password for :string column types with "password" in the method name' do
          default_input_type(:string, :password).should == :password
          default_input_type(:string, :hashed_password).should == :password
          default_input_type(:string, :password_hash).should == :password
        end

        it 'should default to :text for :text column types' do
          default_input_type(:text).should == :text
        end

        it 'should default to :date for :date column types' do
          default_input_type(:date).should == :date
        end

        it 'should default to :datetime for :datetime and :timestamp column types' do
          default_input_type(:datetime).should == :datetime
          default_input_type(:timestamp).should == :datetime
        end

        it 'should default to :time for :time column types' do
          default_input_type(:time).should == :time
        end

        it 'should default to :boolean for :boolean column types' do
          default_input_type(:boolean).should == :boolean
        end

        it 'should default to :string for :string column types' do
          default_input_type(:string).should == :string
        end

        it 'should default to :numeric for :integer, :float and :decimal column types' do
          default_input_type(:integer).should == :numeric
          default_input_type(:float).should == :numeric
          default_input_type(:decimal).should == :numeric
        end
        
        it 'should default to :country for :string columns named country' do
          default_input_type(:string, :country).should == :country
        end

        describe 'defaulting to file column' do
          Formtastic::SemanticFormBuilder.file_methods.each do |method|
            it "should default to :file for attributes that respond to ##{method}" do
              @new_post.stub!(:column_for_attribute).and_return(nil)
              column = mock('column')

              Formtastic::SemanticFormBuilder.file_methods.each do |test|
                column.stub!(:respond_to?).with(test).and_return(method == test)
              end

              @new_post.should_receive(method).and_return(column)

              semantic_form_for(@new_post) do |builder|
                builder.send(:default_input_type, method).should == :file
              end
            end
          end

        end
      end

      it 'should call the corresponding input method' do
        [:select, :time_zone, :radio, :date, :datetime, :time, :boolean, :check_boxes, :hidden].each do |input_style|
          @new_post.stub!(:generic_column_name)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
          semantic_form_for(@new_post) do |builder|
            builder.should_receive(:"#{input_style}_input").once.and_return("fake HTML output from #input")
            concat(builder.input(:generic_column_name, :as => input_style))
          end
        end

        [:string, :password, :numeric, :text, :file].each do |input_style|
          @new_post.stub!(:generic_column_name)
          @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :string, :limit => 255))
          semantic_form_for(@new_post) do |builder|
            builder.should_receive(:basic_input_helper).once.and_return("fake HTML output from #input")
            concat(builder.input(:generic_column_name, :as => input_style))
          end
        end
      end

    end

    describe ':label option' do
      
      describe 'when provided' do
        it 'should be passed down to the label tag' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => "Kustom"))
          end
          output_buffer.should have_tag("form li label", /Kustom/)
        end

        it 'should not generate a label if false' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => false))
          end
          output_buffer.should_not have_tag("form li label")
        end

        it 'should be dupped if frozen' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => "Kustom".freeze))
          end
          output_buffer.should have_tag("form li label", /Kustom/)
        end
      end

      describe 'when not provided' do
        describe 'when localized label is NOT provided' do
          describe 'and object is not given' do
            it 'should default the humanized method name, passing it down to the label tag' do
              Formtastic::SemanticFormBuilder.label_str_method = :humanize
          
              semantic_form_for(:project, :url => 'http://test.host') do |builder|
                concat(builder.input(:meta_description))
              end
          
              output_buffer.should have_tag("form li label", /#{'meta_description'.humanize}/)
            end
          end
          
          describe 'and object is given' do
            it 'should delegate the label logic to class human attribute name and pass it down to the label tag' do
              @new_post.stub!(:meta_description) # a two word method name
              @new_post.class.should_receive(:human_attribute_name).with('meta_description').and_return('meta_description'.humanize)
          
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:meta_description))
              end
          
              output_buffer.should have_tag("form li label", /#{'meta_description'.humanize}/)
            end
          end
        end
        
        describe 'when localized label is provided' do
          before do
            @localized_label_text = 'Localized title'
            @default_localized_label_text = 'Default localized title'
            ::I18n.backend.store_translations :en,
              :formtastic => {
                  :labels => {
                    :title => @default_localized_label_text,
                    :published => @default_localized_label_text,
                    :post => {
                      :title => @localized_label_text,
                      :published => @default_localized_label_text
                     }
                   }
                }
            ::Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false
          end

          it 'should render a label with localized label (I18n)' do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :label => true))
              concat(builder.input(:published, :as => :boolean, :label => true))
            end
            output_buffer.should have_tag('form li label', @localized_label_text)
          end

          it 'should render a hint paragraph containing an optional localized label (I18n) if first is not set' do
            ::I18n.backend.store_translations :en,
              :formtastic => {
                  :labels => {
                    :post => {
                      :title => nil,
                      :published => nil
                     }
                   }
                }
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :label => true))
              concat(builder.input(:published, :as => :boolean, :label => true))
            end
            output_buffer.should have_tag('form li label', @default_localized_label_text)
          end
        end
      end
      
    end

    describe ':hint option' do

      describe 'when provided' do
        it 'should be passed down to the paragraph tag' do
          hint_text = "this is the title of the post"
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :hint => hint_text))
          end
          output_buffer.should have_tag("form li p.inline-hints", hint_text)
        end
      end

      describe 'when not provided' do
        describe 'when localized hint (I18n) is provided' do
          before do
            @localized_hint_text = "This is the localized hint."
            @default_localized_hint_text = "This is the default localized hint."
            ::I18n.backend.store_translations :en,
              :formtastic => {
                  :hints => {
                    :title => @default_localized_hint_text,
                    :post => {
                      :title => @localized_hint_text
                     }
                   }
                }
            ::Formtastic::SemanticFormBuilder.i18n_lookups_by_default = false
          end
          
          describe 'when provided value (hint value) is set to TRUE' do
            it 'should render a hint paragraph containing a localized hint (I18n)' do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :hint => true))
              end
              output_buffer.should have_tag('form li p.inline-hints', @localized_hint_text)
            end
            
            it 'should render a hint paragraph containing an optional localized hint (I18n) if first is not set' do
              ::I18n.backend.store_translations :en,
              :formtastic => {
                  :hints => {
                    :post => {
                      :title => nil
                     }
                   }
                }
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :hint => true))
              end
              output_buffer.should have_tag('form li p.inline-hints', @default_localized_hint_text)
            end
          end
          
          describe 'when provided value (label value) is set to FALSE' do
            it 'should not render a hint paragraph' do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :hint => false))
              end
              output_buffer.should_not have_tag('form li p.inline-hints', @localized_hint_text)
            end
          end
        end
        
        describe 'when localized hint (I18n) is not provided' do
          it 'should not render a hint paragraph' do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title))
            end
            output_buffer.should_not have_tag('form li p.inline-hints')
          end
        end
      end

    end

    describe ':wrapper_html option' do

      describe 'when provided' do
        it 'should be passed down to the li tag' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:id => :another_id}))
          end
          output_buffer.should have_tag("form li#another_id")
        end

        it 'should append given classes to li default classes' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:class => :another_class}, :required => true))
          end
          output_buffer.should have_tag("form li.string")
          output_buffer.should have_tag("form li.required")
          output_buffer.should have_tag("form li.another_class")
        end

        it 'should allow classes to be an array' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:class => [ :my_class, :another_class ]}))
          end
          output_buffer.should have_tag("form li.string")
          output_buffer.should have_tag("form li.my_class")
          output_buffer.should have_tag("form li.another_class")
        end
      end

      describe 'when not provided' do
        it 'should use default id and class' do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title))
          end
          output_buffer.should have_tag("form li#post_title_input")
          output_buffer.should have_tag("form li.string")
        end
      end

    end
  end

  describe ':as => :string' do
    
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :string))
      end
    end
        
    it_should_have_input_wrapper_with_class(:string)
    it_should_have_input_wrapper_with_id("post_title_input")
    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("post_title")
    it_should_have_input_with_id("post_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("post[title]")
    it_should_have_maxlength_matching_column_limit
    it_should_use_default_text_field_size_for_columns_longer_than_default_text_field_size(:string)
    it_should_use_column_size_for_columns_shorter_than_default_text_field_size(:string)
    it_should_use_default_text_field_size_when_method_has_no_database_column(:string)
    it_should_apply_custom_input_attributes_when_input_html_provided(:string)
    it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
    it_should_apply_error_logic_for_input_type(:string)
    
    describe "when no object is provided" do
      before do
        semantic_form_for(:project, :url => 'http://test.host/') do |builder|
          concat(builder.input(:title, :as => :string))
        end
      end
      
      it_should_have_label_with_text(/Title/)
      it_should_have_label_for("project_title")
      it_should_have_input_with_id("project_title")
      it_should_have_input_with_type(:text)
      it_should_have_input_with_name("project[title]")
    end
  
  end
  
  describe ':as => :password' do
    
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :password))
      end
    end
        
    it_should_have_input_wrapper_with_class(:password)
    it_should_have_input_wrapper_with_id("post_title_input")
    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("post_title")
    it_should_have_input_with_id("post_title")
    it_should_have_input_with_type(:password)
    it_should_have_input_with_name("post[title]")
    it_should_have_maxlength_matching_column_limit
    it_should_use_default_text_field_size_for_columns_longer_than_default_text_field_size(:string)
    it_should_use_column_size_for_columns_shorter_than_default_text_field_size(:string)
    it_should_use_default_text_field_size_when_method_has_no_database_column(:string)
    it_should_apply_custom_input_attributes_when_input_html_provided(:string)
    it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
    it_should_apply_error_logic_for_input_type(:password)
    
    describe "when no object is provided" do
      before do
        semantic_form_for(:project, :url => 'http://test.host/') do |builder|
          concat(builder.input(:title, :as => :password))
        end
      end
      
      it_should_have_label_with_text(/Title/)
      it_should_have_label_for("project_title")
      it_should_have_input_with_id("project_title")
      it_should_have_input_with_type(:password)
      it_should_have_input_with_name("project[title]")
    end
  
  end
  
  describe ':as => :numeric' do
    
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :numeric))
      end
    end
        
    it_should_have_input_wrapper_with_class(:numeric)
    it_should_have_input_wrapper_with_id("post_title_input")
    it_should_have_label_with_text(/Title/)
    it_should_have_label_for("post_title")
    it_should_have_input_with_id("post_title")
    it_should_have_input_with_type(:text)
    it_should_have_input_with_name("post[title]")
    it_should_use_default_text_field_size_when_method_has_no_database_column(:string)
    it_should_apply_custom_input_attributes_when_input_html_provided(:string)
    it_should_apply_custom_for_to_label_when_input_html_id_provided(:string)
    it_should_apply_error_logic_for_input_type(:numeric)
    
    describe "when no object is provided" do
      before do
        semantic_form_for(:project, :url => 'http://test.host/') do |builder|
          concat(builder.input(:title, :as => :numeric))
        end
      end
      
      it_should_have_label_with_text(/Title/)
      it_should_have_label_for("project_title")
      it_should_have_input_with_id("project_title")
      it_should_have_input_with_type(:text)
      it_should_have_input_with_name("project[title]")
    end
  
  end

  describe ":as => :text" do
    
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:body, :as => :text))
      end
    end
    
    it_should_have_input_wrapper_with_class("text")
    it_should_have_input_wrapper_with_id("post_body_input")
    it_should_have_label_with_text(/Body/)
    it_should_have_label_for("post_body")
    it_should_have_textarea_with_id("post_body")
    it_should_have_textarea_with_name("post[body]")
    it_should_apply_error_logic_for_input_type(:numeric)
    
    it 'should use input_html to style inputs' do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :text, :input_html => { :class => 'myclass' }))
      end
      output_buffer.should have_tag("form li textarea.myclass")
    end
    
  end
  
  describe ":as => :file" do
    
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:body, :as => :file))
      end
    end
    
    it_should_have_input_wrapper_with_class("file")
    it_should_have_input_wrapper_with_id("post_body_input")
    it_should_have_label_with_text(/Body/)
    it_should_have_label_for("post_body")
    it_should_have_input_with_id("post_body")
    it_should_have_input_with_name("post[body]")
    it_should_apply_error_logic_for_input_type(:file)

    it 'should use input_html to style inputs' do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, :as => :file, :input_html => { :class => 'myclass' }))
      end
      output_buffer.should have_tag("form li input.myclass")
    end
    
  end
  
  describe ":as => :hidden" do
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:secret, :as => :hidden))
      end
    end
    
    it_should_have_input_wrapper_with_class("hidden")
    it_should_have_input_wrapper_with_id("post_secret_input")
    it_should_not_have_a_label

    it "should generate a input field" do
      output_buffer.should have_tag("form li input#post_secret")
      output_buffer.should have_tag("form li input[@type=\"hidden\"]")
      output_buffer.should have_tag("form li input[@name=\"post[secret]\"]")
    end
    
    it "should not render inline errors" do
      @errors = mock('errors')
      @errors.stub!(:[]).with(:secret).and_return(["foo", "bah"])
      @new_post.stub!(:errors).and_return(@errors)
      
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:secret, :as => :hidden))
      end
      
      output_buffer.should_not have_tag("form li p.inline-errors")
      output_buffer.should_not have_tag("form li ul.errors")
    end
    
  end

  describe ":as => :time_zone" do
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:time_zone))
      end
    end
    
    it_should_have_input_wrapper_with_class("time_zone")
    it_should_have_input_wrapper_with_id("post_time_zone_input")
    it_should_apply_error_logic_for_input_type(:time_zone)
    
    it 'should generate a label for the input' do
      output_buffer.should have_tag('form li label')
      output_buffer.should have_tag('form li label[@for="post_time_zone"]')
      output_buffer.should have_tag('form li label', /Time zone/)
    end

    it "should generate a select" do
      output_buffer.should have_tag("form li select")
      output_buffer.should have_tag("form li select#post_time_zone")
      output_buffer.should have_tag("form li select[@name=\"post[time_zone]\"]")
    end

    it 'should use input_html to style inputs' do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:time_zone, :input_html => { :class => 'myclass' }))
      end
      output_buffer.should have_tag("form li select.myclass")
    end

    describe 'when no object is given' do
      before(:each) do
        semantic_form_for(:project, :url => 'http://test.host/') do |builder|
          concat(builder.input(:time_zone, :as => :time_zone))
        end
      end

      it 'should generate labels' do
        output_buffer.should have_tag('form li label')
        output_buffer.should have_tag('form li label[@for="project_time_zone"]')
        output_buffer.should have_tag('form li label', /Time zone/)
      end

      it 'should generate select inputs' do
        output_buffer.should have_tag("form li select")
        output_buffer.should have_tag("form li select#project_time_zone")
        output_buffer.should have_tag("form li select[@name=\"project[time_zone]\"]")
      end
    end
  end
  
  describe ":as => :country" do
    
    describe "when country_select is not available as a helper from a plugin" do
      
      it "should raise an error, sugesting the author installs a plugin" do
        lambda { 
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:country, :as => :country))
          end
        }.should raise_error  
      end
      
    end
    
    describe "when country_select is available as a helper (from a plugin)" do
      
      before do
        semantic_form_for(@new_post) do |builder|
          builder.stub!(:country_select).and_return("<select><option>...</option></select>")
          concat(builder.input(:country, :as => :country))
        end
      end
      
      it_should_have_input_wrapper_with_class("country")
      it_should_have_input_wrapper_with_id("post_country_input")
      
      # TODO -- needs stubbing inside the builder block, tricky!
      #it_should_apply_error_logic_for_input_type(:country)

      it 'should generate a label for the input' do
        output_buffer.should have_tag('form li label')
        output_buffer.should have_tag('form li label[@for="post_country"]')
        output_buffer.should have_tag('form li label', /Country/)
      end

      it "should generate a select" do
        output_buffer.should have_tag("form li select")
      end
      
    end
    
    describe ":priority_countries option" do
        
      it "should be passed down to the country_select helper when provided" do
        priority_countries = ["Foo", "Bah"]
        semantic_form_for(@new_post) do |builder|
          builder.stub!(:country_select).and_return("<select><option>...</option></select>")
          builder.should_receive(:country_select).with(:country, priority_countries, {}, {}).and_return("<select><option>...</option></select>")
          
          concat(builder.input(:country, :as => :country, :priority_countries => priority_countries))
        end
      end
        
      it "should default to the @@priority_countries config when absent" do 
        priority_countries = Formtastic::SemanticFormBuilder.priority_countries
        priority_countries.should_not be_empty
        priority_countries.should_not be_nil
        
        semantic_form_for(@new_post) do |builder|
          builder.stub!(:country_select).and_return("<select><option>...</option></select>")
          builder.should_receive(:country_select).with(:country, priority_countries, {}, {}).and_return("<select><option>...</option></select>")
          
          concat(builder.input(:country, :as => :country))
        end
      end
      
    end
    
  end
  
  describe ':as => :radio' do
    describe 'for belongs_to association' do
      before do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :radio, :value_as_class => true))
        end
      end
      
      it_should_have_input_wrapper_with_class("radio")
      it_should_have_input_wrapper_with_id("post_author_input")
      it_should_have_a_nested_fieldset
      it_should_apply_error_logic_for_input_type(:radio)
      
      it 'should generate a legend containing label text for the input' do
        output_buffer.should have_tag('form li fieldset legend')
        output_buffer.should have_tag('form li fieldset legend', /Author/)
      end

      it 'should generate an ordered list with a list item for each choice' do
        output_buffer.should have_tag('form li fieldset ol')
        output_buffer.should have_tag('form li fieldset ol li', :count => ::Author.find(:all).size)
      end

      it 'should have one option with a "checked" attribute' do
        output_buffer.should have_tag('form li input[@checked]', :count => 1)
      end

      describe "each choice" do

        it 'should contain a label for the radio input with a nested input and label text' do
          ::Author.find(:all).each do |author|
            output_buffer.should have_tag('form li fieldset ol li label', /#{author.to_label}/)
            output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_id_#{author.id}']")
          end
        end

        it 'should use values as li.class when value_as_class is true' do
          ::Author.find(:all).each do |author|
            output_buffer.should have_tag("form li fieldset ol li.#{author.id} label")
          end
        end

        it "should have a radio input" do
          ::Author.find(:all).each do |author|
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

          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:author, :as => :radio))
          end

          output_buffer.should have_tag("form li fieldset ol li label input[@checked='checked']")
        end
      end

      describe 'and no object is given' do
        before(:each) do
          output_buffer.replace ''
          semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.input(:author_id, :as => :radio, :collection => ::Author.find(:all)))
          end
        end

        it 'should generate a fieldset with legend' do
          output_buffer.should have_tag('form li fieldset legend', /Author/)
        end

        it 'should generate an li tag for each item in the collection' do
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
            output_buffer.should have_tag("form li fieldset ol li label input[@type='radio']")
            output_buffer.should have_tag("form li fieldset ol li label input[@value='#{author.id}']")
            output_buffer.should have_tag("form li fieldset ol li label input[@name='project[author_id]']")
          end
        end
      end
    end
  end

 
  describe ':as => :select' do

    before do
      @new_post.stub!(:author).and_return(@bob)
      @new_post.stub!(:author_id).and_return(@bob.id)
      @new_post.stub!(:column_for_attribute).and_return(mock('column', :type => :integer, :limit => 255))
      # instances for the group_by part
      @continent_names = %w(Europe Africa)
      @authors = [@bob, @fred]
      @continents = (0..1).map { |i| mock("continent", :id => (100 - i) ) }
      @authors[0..1].each_with_index { |author, i| author.stub!(:continent).and_return(@continents[i]) }
    
      @continents.each_with_index do |continent, i| 
        continent.stub!(:to_label).and_return(@continent_names[i])
        continent.stub!(:authors).and_return([@authors[i]])
      end
    end

    [{}, { :group_by => :continent }].each do |options|
      describe 'for a belongs_to association' do
        before do
          semantic_form_for(@new_post) do |builder|
            concat(builder.input(:author, options.merge(:as => :select) ) )
          end
        end
        
        it_should_have_input_wrapper_with_class("select")
        it_should_have_input_wrapper_with_id("post_author_input")
        it_should_have_label_with_text(/Author/)
        it_should_have_label_for('post_author_id')
        
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
    end

    describe 'for a belongs_to association and :group_by => :continent' do
      before do
        @authors = [@bob, @fred, @fred, @fred]
        ::Author.stub!(:find).and_return(@authors)
        
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:author, :as => :select, :group_by => :continent ) )
          concat(builder.input(:author, :as => :select, :group_by => :continent, :group_label_method => :id ) )
        end
      end

      it_should_have_input_wrapper_with_class("select")
      it_should_have_input_wrapper_with_id("post_author_input")
      it_should_have_label_with_text(/Author/)
      it_should_have_label_for('post_author_id')
      it_should_apply_error_logic_for_input_type(:select)
      it_should_call_find_on_association_class_when_no_collection_is_provided(:select)

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
  
  end

  describe ':as => :check_boxes' do
    describe 'for a has_many association' do
      before do
        semantic_form_for(@fred) do |builder|
          concat(builder.input(:posts, :as => :check_boxes, :value_as_class => true))
        end
      end
      
      it_should_have_input_wrapper_with_class("check_boxes")
      it_should_have_input_wrapper_with_id("author_posts_input")
      it_should_have_a_nested_fieldset
      it_should_apply_error_logic_for_input_type(:check_boxes)
      it_should_call_find_on_association_class_when_no_collection_is_provided(:check_boxes)
      
      it 'should generate a legend containing label text for the input' do
        output_buffer.should have_tag('form li fieldset legend')
        output_buffer.should have_tag('form li fieldset legend', /Posts/)
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

  describe 'for collections' do

    { :select => :option, :radio => :input, :check_boxes => :'input[@type="checkbox"]' }.each do |type, countable|

      describe ":as => #{type.inspect}" do
        
        describe 'when the :collection option is provided' do

          before do
            @authors = ::Author.find(:all) * 2
            output_buffer.replace '' # clears the output_buffer from the before block, hax!
          end

          it 'should not call find() on the parent class' do
            ::Author.should_not_receive(:find)
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:author, :as => type, :collection => @authors))
            end
          end

          it 'should use the provided collection' do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:author, :as => type, :collection => @authors))
            end
            output_buffer.should have_tag("form li.#{type} #{countable}", :count => @authors.size + (type == :select ? 1 : 0))
          end

          describe 'and the :collection is an array of strings' do
            before do
              @categories = [ 'General', 'Design', 'Development', 'Quasi-Serious Inventions' ]
            end

            it "should use the string as the label text and value for each #{countable}" do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:category_name, :as => type, :collection => @categories))
              end

              @categories.each do |value|
                output_buffer.should have_tag("form li.#{type}", /#{value}/)
                output_buffer.should have_tag("form li.#{type} #{countable}[@value='#{value}']")
              end
            end

            if type == :radio
              it 'should generate a sanitized label for attribute' do
                @bob.stub!(:category_name).and_return(@categories)
                semantic_form_for(@new_post) do |builder|
                  builder.semantic_fields_for(@bob) do |bob_builder|
                    concat(bob_builder.input(:category_name, :as => type, :collection => @categories))
                  end
                end
                output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_general']")
                output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_design']")
                output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_development']")
                output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_category_name_quasiserious_inventions']")
              end
            end
          end

          describe 'and the :collection is a hash of strings' do
            before do
              @categories = { 'General' => 'gen', 'Design' => 'des','Development' => 'dev' }
            end

            it "should use the key as the label text and the hash value as the value attribute for each #{countable}" do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:category_name, :as => type, :collection => @categories))
              end

              @categories.each do |label, value|
                output_buffer.should have_tag("form li.#{type}", /#{label}/)
                output_buffer.should have_tag("form li.#{type} #{countable}[@value='#{value}']")
              end
            end
          end

          describe 'and the :collection is an array of arrays' do
            before do
              @categories = { 'General' => 'gen', 'Design' => 'des', 'Development' => 'dev' }.to_a
            end

            it "should use the first value as the label text and the last value as the value attribute for #{countable}" do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:category_name, :as => type, :collection => @categories))
              end

              @categories.each do |text, value|
                label = type == :select ? :option : :label
                output_buffer.should have_tag("form li.#{type} #{label}", /#{text}/i)
                output_buffer.should have_tag("form li.#{type} #{countable}[@value='#{value.to_s}']")
                output_buffer.should have_tag("form li.#{type} #{countable}#post_category_name_#{value.to_s}") if type == :radio
              end
            end
          end
          
          if type == :radio
            describe 'and the :collection is an array of arrays with boolean values' do
              before do
                @choices = { 'Yeah' => true, 'Nah' => false }.to_a
              end
          
              it "should use the first value as the label text and the last value as the value attribute for #{countable}" do
                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:category_name, :as => type, :collection => @choices))
                end
                
                output_buffer.should have_tag("form li.#{type} #{countable}#post_category_name_true")
                output_buffer.should have_tag("form li.#{type} #{countable}#post_category_name_false")
              end
            end
          end
          
          
          describe 'and the :collection is an array of symbols' do
            before do
              @categories = [ :General, :Design, :Development ]
            end

            it "should use the symbol as the label text and value for each #{countable}" do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:category_name, :as => type, :collection => @categories))
              end

              @categories.each do |value|
                label = type == :select ? :option : :label
                output_buffer.should have_tag("form li.#{type} #{label}", /#{value}/i)
                output_buffer.should have_tag("form li.#{type} #{countable}[@value='#{value.to_s}']")
              end
            end
          end
          
          describe 'and the :collection is an OrderedHash of strings' do
            before do
              @categories = ActiveSupport::OrderedHash.new('General' => 'gen', 'Design' => 'des','Development' => 'dev')
            end

            it "should use the key as the label text and the hash value as the value attribute for each #{countable}" do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:category_name, :as => type, :collection => @categories))
              end

              @categories.each do |label, value|
                output_buffer.should have_tag("form li.#{type}", /#{label}/)
                output_buffer.should have_tag("form li.#{type} #{countable}[@value='#{value}']")
              end
            end
            
          end
          
          describe 'when the :label_method option is provided' do
            
            describe 'as a symbol' do
              before do
                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:author, :as => type, :label_method => :login))
                end
              end

              it 'should have options with text content from the specified method' do
                ::Author.find(:all).each do |author|
                  output_buffer.should have_tag("form li.#{type}", /#{author.login}/)
                end
              end
            end
            
            describe 'as a proc' do
              before do
                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:author, :as => type, :label_method => Proc.new {|a| a.login.reverse }))
                end
              end
              
              it 'should have options with the proc applied to each' do
                ::Author.find(:all).each do |author|
                  output_buffer.should have_tag("form li.#{type}", /#{author.login.reverse}/)
                end
              end
            end
            
          end

          describe 'when the :label_method option is not provided' do
            Formtastic::SemanticFormBuilder.collection_label_methods.each do |label_method|

              describe "when the collection objects respond to #{label_method}" do
                before do
                  @fred.stub!(:respond_to?).and_return { |m| m.to_s == label_method }
                  ::Author.find(:all).each { |a| a.stub!(label_method).and_return('The Label Text') }

                  semantic_form_for(@new_post) do |builder|
                    concat(builder.input(:author, :as => type))
                  end
                end

                it "should render the options with #{label_method} as the label" do
                  ::Author.find(:all).each do |author|
                    output_buffer.should have_tag("form li.#{type}", /The Label Text/)
                  end
                end
              end

            end
          end

          describe 'when the :value_method option is provided' do
            
            describe 'as a symbol' do
              before do
                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:author, :as => type, :value_method => :login))
                end
              end
              
              it 'should have options with values from specified method' do
                ::Author.find(:all).each do |author|
                  output_buffer.should have_tag("form li.#{type} #{countable}[@value='#{author.login}']")
                end
              end
            end
            
            describe 'as a proc' do
              before do
                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:author, :as => type, :value_method => Proc.new {|a| a.login.reverse }))
                end
              end

              it 'should have options with the proc applied to each value' do
                ::Author.find(:all).each do |author|
                  output_buffer.should have_tag("form li.#{type} #{countable}[@value='#{author.login.reverse}']")
                end
              end
            end
          end

        end
      
      end
    end

    describe 'for boolean attributes' do

      { :select => :option, :radio => :input }.each do |type, countable|
        checked_or_selected = { :select => :selected, :radio => :checked }[type]

        describe ":as => #{type.inspect}" do

          before do
            semantic_form_for(@new_post) do |builder|
              concat(builder.input(:allow_comments, :as => type))
            end
          end
          
          it_should_have_input_wrapper_with_class(type)
          it_should_have_input_wrapper_with_id("post_allow_comments_input")

          it 'should generate a fieldset containing a legend' do
            output_buffer.should have_tag("form li.#{type}", /Allow comments/)
          end

          it "should generate two #{countable}" do
            output_buffer.should have_tag("form li.#{type} #{countable}", :count => (type == :select ? 3 : 2))
            output_buffer.should have_tag(%{form li.#{type} #{countable}[@value="true"]})
            output_buffer.should have_tag(%{form li.#{type} #{countable}[@value="false"]})
          end

          describe 'when the locale sets the label text' do
            before do
              I18n.backend.store_translations 'en', :formtastic => {:yes => 'Absolutely!', :no => 'Never!'}

              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:allow_comments, :as => type))
              end
            end

            after do
              I18n.backend.store_translations 'en', :formtastic => {:yes => nil, :no => nil}
            end

            it 'should allow translation of the labels' do
              output_buffer.should have_tag("form li.#{type}", /Absolutely\!/)
              output_buffer.should have_tag("form li.#{type}", /Never\!/)
            end
          end

          describe 'when the value is nil' do
            before do
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:allow_comments, :as => type))
              end
            end

            it "should not mark either #{countable} as #{checked_or_selected}" do
              output_buffer.should_not have_tag(%{form li.#{type} input[@#{checked_or_selected}="#{checked_or_selected}"]})
            end
          end

          describe 'when the value is true' do
            before do
              @new_post.stub!(:allow_comments).and_return(true)
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:allow_comments, :as => type))
              end
            end

            it "should mark the true #{countable} as #{checked_or_selected}" do
              output_buffer.should have_tag(%{form li.#{type} #{countable}[@value="true"][@#{checked_or_selected}="#{checked_or_selected}"]}, :count => 1)
            end

            it "should not mark the false #{countable} as #{checked_or_selected}" do
              output_buffer.should_not have_tag(%{form li.#{type} #{countable}[@value="false"][@#{checked_or_selected}="#{checked_or_selected}"]})
            end
          end

          describe 'when the value is false' do
            before do
              @new_post.stub!(:allow_comments).and_return(false)
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:allow_comments, :as => type))
              end
            end

            it "should not mark the true #{countable} as #{checked_or_selected}" do
              output_buffer.should_not have_tag(%{form li.#{type} #{countable}[@value="true"][@#{checked_or_selected}="#{checked_or_selected}"]})
            end

            it "should mark the false #{countable} as #{checked_or_selected}" do
              output_buffer.should have_tag(%{form li.#{type} #{countable}[@value="false"][@#{checked_or_selected}="#{checked_or_selected}"]}, :count => 1)
            end
          end

          describe 'when :true and :false options are provided' do
            before do
              @new_post.stub!(:allow_comments)
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:allow_comments, :as => type, :true => "Absolutely", :false => "No Way"))
              end
            end

            it 'should use them as labels' do
              output_buffer.should have_tag("form li.#{type}", /Absolutely/)
              output_buffer.should have_tag("form li.#{type}", /No Way/)
            end
          end
          
          describe 'when the :selected option is excluded' do

            before do
              @output_buffer = ''
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:allow_comments, :as => type))
              end
            end

            it 'should not pre-select either value' do
              output_buffer.should_not have_tag("form li.#{type} #{countable}[@#{checked_or_selected}]")
            end

          end
          
          describe 'when the :selected option is provided' do
            
            before do
              @output_buffer = ''
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:allow_comments, :as => type, :selected => true))
              end
            end

            it 'should pre-select the value' do
              output_buffer.should have_tag("form li.#{type} #{countable}[@#{checked_or_selected}]")
            end
          
          end
        
        end
        
      end
    end
  end

  describe ':as => :date' do

    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :date))
      end
    end

    it_should_have_input_wrapper_with_class("date")
    it_should_have_input_wrapper_with_id("post_publish_at_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:date)
    
    it 'should have a legend containing the label text inside the fieldset' do
      output_buffer.should have_tag('form li.date fieldset legend', /Publish at/)
    end

    it 'should have an ordered list of three items inside the fieldset' do
      output_buffer.should have_tag('form li.date fieldset ol')
      output_buffer.should have_tag('form li.date fieldset ol li', :count => 3)
    end

    it 'should have three labels for year, month and day' do
      output_buffer.should have_tag('form li.date fieldset ol li label', :count => 3)
      output_buffer.should have_tag('form li.date fieldset ol li label', /year/i)
      output_buffer.should have_tag('form li.date fieldset ol li label', /month/i)
      output_buffer.should have_tag('form li.date fieldset ol li label', /day/i)
    end

    it 'should have three selects for year, month and day' do
      output_buffer.should have_tag('form li.date fieldset ol li select', :count => 3)
    end
  end

  describe ':as => :datetime' do

    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :datetime))
      end
    end

    it_should_have_input_wrapper_with_class("datetime")
    it_should_have_input_wrapper_with_id("post_publish_at_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:datetime)
    
    it 'should have a legend containing the label text inside the fieldset' do
      output_buffer.should have_tag('form li.datetime fieldset legend', /Publish at/)
    end

    it 'should have an ordered list of five items inside the fieldset' do
      output_buffer.should have_tag('form li.datetime fieldset ol')
      output_buffer.should have_tag('form li.datetime fieldset ol li', :count => 5)
    end

    it 'should have five labels for year, month, day, hour and minute' do
      output_buffer.should have_tag('form li.datetime fieldset ol li label', :count => 5)
      output_buffer.should have_tag('form li.datetime fieldset ol li label', /year/i)
      output_buffer.should have_tag('form li.datetime fieldset ol li label', /month/i)
      output_buffer.should have_tag('form li.datetime fieldset ol li label', /day/i)
      output_buffer.should have_tag('form li.datetime fieldset ol li label', /hour/i)
      output_buffer.should have_tag('form li.datetime fieldset ol li label', /minute/i)
    end

    it 'should have five selects for year, month, day, hour and minute' do
      output_buffer.should have_tag('form li.datetime fieldset ol li select', :count => 5)
    end

    it 'should generate a sanitized label and matching ids for attribute' do
      semantic_form_for(@new_post) do |builder|
        builder.semantic_fields_for(@bob, :index => 10) do |bob_builder|
          concat(bob_builder.input(:created_at, :as => :datetime))
        end
      end

      1.upto(5) do |i|
        output_buffer.should have_tag("form li fieldset ol li label[@for='post_author_10_created_at_#{i}i']")
        output_buffer.should have_tag("form li fieldset ol li #post_author_10_created_at_#{i}i")
      end
    end

    describe 'when :discard_input => true is set' do
      it 'should use default hidden value equals to 1 when attribute returns nil' do
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :datetime, :discard_day => true))
        end

        output_buffer.should have_tag("form li input[@type='hidden'][@value='1']")
      end

      it 'should use default attribute value when it is not nil' do
        @new_post.stub!(:publish_at).and_return(Date.new(2007,12,27))
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :datetime, :discard_day => true))
        end

        output_buffer.should have_tag("form li input[@type='hidden'][@value='27']")
      end
    end

    describe 'inputs order' do
      it 'should have a default' do
        semantic_form_for(@new_post) do |builder|
          self.should_receive(:select_year).once.ordered.and_return('')
          self.should_receive(:select_month).once.ordered.and_return('')
          self.should_receive(:select_day).once.ordered.and_return('')
          builder.input(:publish_at, :as => :datetime)
        end
      end

      it 'should be specified with :order option' do
        I18n.backend.store_translations 'en', :date => { :order => [:month, :year, :day] }
        semantic_form_for(@new_post) do |builder|
          self.should_receive(:select_month).once.ordered.and_return('')
          self.should_receive(:select_year).once.ordered.and_return('')
          self.should_receive(:select_day).once.ordered.and_return('')
          builder.input(:publish_at, :as => :datetime)
        end
      end

      it 'should be changed through I18n' do
        semantic_form_for(@new_post) do |builder|
          self.should_receive(:select_day).once.ordered.and_return('')
          self.should_receive(:select_month).once.ordered.and_return('')
          self.should_receive(:select_year).once.ordered.and_return('')
          builder.input(:publish_at, :as => :datetime, :order => [:day, :month, :year])
        end
      end
    end

    describe 'when the locale changes the label text' do
      before do
        I18n.backend.store_translations 'en', :datetime => {:prompts => {
          :year => 'The Year', :month => 'The Month', :day => 'The Day',
          :hour => 'The Hour', :minute => 'The Minute'
        }}
        semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :datetime))
        end
      end

      after do
        I18n.backend.store_translations 'en', :formtastic => {
          :year => nil, :month => nil, :day => nil,
          :hour => nil, :minute => nil
        }
      end

      it 'should have translated labels for year, month, day, hour and minute' do
        output_buffer.should have_tag('form li.datetime fieldset ol li label', /The Year/)
        output_buffer.should have_tag('form li.datetime fieldset ol li label', /The Month/)
        output_buffer.should have_tag('form li.datetime fieldset ol li label', /The Day/)
        output_buffer.should have_tag('form li.datetime fieldset ol li label', /The Hour/)
        output_buffer.should have_tag('form li.datetime fieldset ol li label', /The Minute/)
      end
    end

    describe 'when no object is given' do
      before(:each) do
        output_buffer.replace ''
        semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:publish_at, :as => :datetime))
        end
      end

      it 'should have fieldset with legend' do
        output_buffer.should have_tag('form li.datetime fieldset legend', /Publish at/)
      end

      it 'should have labels for each input' do
        output_buffer.should have_tag('form li.datetime fieldset ol li label', :count => 5)
      end

      it 'should have selects for each inputs' do
        output_buffer.should have_tag('form li.datetime fieldset ol li select', :count => 5)
      end
    end
  end

  describe ':as => :time' do
    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :time))
      end
    end
    
    it_should_have_input_wrapper_with_class("time")
    it_should_have_input_wrapper_with_id("post_publish_at_input")
    it_should_have_a_nested_fieldset
    it_should_apply_error_logic_for_input_type(:time)

    it 'should have a legend containing the label text inside the fieldset' do
      output_buffer.should have_tag('form li.time fieldset legend', /Publish at/)
    end

    it 'should have an ordered list of two items inside the fieldset' do
      output_buffer.should have_tag('form li.time fieldset ol')
      output_buffer.should have_tag('form li.time fieldset ol li', :count => 2)
    end

    it 'should have five labels for hour and minute' do
      output_buffer.should have_tag('form li.time fieldset ol li label', :count => 2)
      output_buffer.should have_tag('form li.time fieldset ol li label', /hour/i)
      output_buffer.should have_tag('form li.time fieldset ol li label', /minute/i)
    end

    it 'should have two selects for hour and minute' do
      output_buffer.should have_tag('form li.time fieldset ol li', :count => 2)
    end
  end

  describe ':as => :boolean' do

    before do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:allow_comments, :as => :boolean))
      end
    end
    
    it_should_have_input_wrapper_with_class("boolean")
    it_should_have_input_wrapper_with_id("post_allow_comments_input")
    it_should_apply_error_logic_for_input_type(:boolean)
    
    it 'should generate a label containing the input' do
      output_buffer.should have_tag('form li label', :count => 1)
      output_buffer.should have_tag('form li label[@for="post_allow_comments"]')
      output_buffer.should have_tag('form li label', /Allow comments/)
      output_buffer.should have_tag('form li label input[@type="checkbox"]')
    end

    it 'should generate a checkbox input' do
      output_buffer.should have_tag('form li label input')
      output_buffer.should have_tag('form li label input#post_allow_comments')
      output_buffer.should have_tag('form li label input[@type="checkbox"]')
      output_buffer.should have_tag('form li label input[@name="post[allow_comments]"]')
      output_buffer.should have_tag('form li label input[@type="checkbox"][@value="1"]')
    end

    it 'should allow checked and unchecked values to be sent' do
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:allow_comments, :as => :boolean, :checked_value => 'checked', :unchecked_value => 'unchecked'))
      end

      output_buffer.should have_tag('form li label input[@type="checkbox"][@value="checked"]')
      output_buffer.should have_tag('form li label input[@type="hidden"][@value="unchecked"]')
    end

    it 'should generate a label and a checkbox even if no object is given' do
      semantic_form_for(:project, :url => 'http://test.host') do |builder|
        concat(builder.input(:allow_comments, :as => :boolean))
      end

      output_buffer.should have_tag('form li label[@for="project_allow_comments"]')
      output_buffer.should have_tag('form li label', /Allow comments/)
      output_buffer.should have_tag('form li label input[@type="checkbox"]')

      output_buffer.should have_tag('form li label input#project_allow_comments')
      output_buffer.should have_tag('form li label input[@type="checkbox"]')
      output_buffer.should have_tag('form li label input[@name="project[allow_comments]"]')
    end

  end
end

