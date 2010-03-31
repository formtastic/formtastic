# coding: utf-8
require File.dirname(__FILE__) + '/spec_helper'

describe 'SemanticFormBuilder#input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
  end

  describe 'with inline order customization' do
    it 'should allow input, hints, errors as order' do
      ::Formtastic::SemanticFormBuilder.inline_order = [:input, :hints, :errors]

      semantic_form_for(@new_post) do |builder|
        builder.should_receive(:inline_input_for).once.ordered
        builder.should_receive(:inline_hints_for).once.ordered
        builder.should_receive(:inline_errors_for).once.ordered
        concat(builder.input(:title))
      end
    end

    it 'should allow hints, input, errors as order' do
      ::Formtastic::SemanticFormBuilder.inline_order = [:hints, :input, :errors]

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
          @old_string = ::Formtastic::SemanticFormBuilder.required_string
          @new_string = ::Formtastic::SemanticFormBuilder.required_string = " required yo!" # ensure there's something in the string
          @new_post.class.should_not_receive(:reflect_on_all_validations)
        end

        after do
          ::Formtastic::SemanticFormBuilder.required_string = @old_string
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
          output_buffer.should have_tag('form li.required label', /#{@new_string}$/)
        end

      end

      describe 'when false' do

        before do
          @string = ::Formtastic::SemanticFormBuilder.optional_string = " optional yo!" # ensure there's something in the string
          @new_post.class.should_not_receive(:reflect_on_all_validations)
        end

        after do
          ::Formtastic::SemanticFormBuilder.optional_string = ''
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
            ::Formtastic::SemanticFormBuilder.all_fields_required_by_default.should == true
            ::Formtastic::SemanticFormBuilder.all_fields_required_by_default = false

            semantic_form_for(:project, :url => 'http://test.host/') do |builder|
              concat(builder.input(:title))
            end
            output_buffer.should_not have_tag('form li.required')
            output_buffer.should have_tag('form li.optional')

            ::Formtastic::SemanticFormBuilder.all_fields_required_by_default = true
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
              ::Formtastic::SemanticFormBuilder.all_fields_required_by_default.should == true
              ::Formtastic::SemanticFormBuilder.all_fields_required_by_default = false

              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')

              ::Formtastic::SemanticFormBuilder.all_fields_required_by_default = true
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
          ::Formtastic::SemanticFormBuilder.file_methods.each do |method|
            it "should default to :file for attributes that respond to ##{method}" do
              @new_post.stub!(:column_for_attribute).and_return(nil)
              column = mock('column')

              ::Formtastic::SemanticFormBuilder.file_methods.each do |test|
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
        describe 'when localized label is provided' do 
          describe 'and object is given' do 
            describe 'and label_str_method not default' do
              it 'should render a label with localized label (I18n)' do
                with_config :label_str_method, :capitalize do
                  @localized_label_text = 'Localized title'
                  @new_post.stub!(:meta_description)
                  @new_post.class.should_receive(:human_attribute_name).with('meta_description').and_return(@localized_label_text)
                
                  semantic_form_for(@new_post) do |builder|
                    concat(builder.input(:meta_description))
                  end
                
                  output_buffer.should have_tag('form li label', @localized_label_text)
                end
              end
            end
          end
        end
        
        describe 'when localized label is NOT provided' do
          describe 'and object is not given' do
            it 'should default the humanized method name, passing it down to the label tag' do
              ::Formtastic::SemanticFormBuilder.label_str_method = :humanize

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
          
          describe 'and object is given with label_str_method set to :capitalize' do
            it 'should capitalize method name, passing it down to the label tag' do
              with_config :label_str_method, :capitalize do
                @new_post.stub!(:meta_description)
            
                semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:meta_description))
                end
            
                output_buffer.should have_tag("form li label", /#{'meta_description'.capitalize}/)
              end
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

end

