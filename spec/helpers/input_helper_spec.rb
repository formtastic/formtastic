# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'with input class finder' do
  include_context 'form builder'

  before do
    @errors = double('errors')
    allow(@errors).to receive(:[]).and_return([])
    allow(@new_post).to receive(:errors).and_return(@errors)
  end

  describe 'arguments and options' do

    it 'should require the first argument (the method on form\'s object)' do
      expect {
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input()) # no args passed in at all
        end)
      }.to raise_error(ArgumentError)
    end

    describe ':required option' do

      describe 'when true' do

        it 'should set a "required" class' do
          with_config :required_string, " required yo!" do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :required => true))
            end)
            expect(output_buffer.to_str).not_to have_tag('form li.optional')
            expect(output_buffer.to_str).to have_tag('form li.required')
          end
        end

        it 'should append the "required" string to the label' do
          with_config :required_string, " required yo!" do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :required => true))
            end)
            expect(output_buffer.to_str).to have_tag('form li.required label', :text => /required yo/)
          end
        end
      end

      describe 'when false' do

        before do
          @string = Formtastic::FormBuilder.optional_string = " optional yo!" # ensure there's something in the string
          expect(@new_post.class).not_to receive(:reflect_on_all_validations)
        end

        after do
          Formtastic::FormBuilder.optional_string = ''
        end

        it 'should set an "optional" class' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end)
          expect(output_buffer.to_str).not_to have_tag('form li.required')
          expect(output_buffer.to_str).to have_tag('form li.optional')
        end

        it 'should set and "optional" class also when there is presence validator' do
          expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                     active_model_presence_validator([:title])
                                                                                                 ])
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end)
          expect(output_buffer.to_str).not_to have_tag('form li.required')
          expect(output_buffer.to_str).to have_tag('form li.optional')
        end

        it 'should append the "optional" string to the label' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end)
          expect(output_buffer.to_str).to have_tag('form li.optional label', :text => /#{@string}$/)
        end

      end

      describe 'when not provided' do

        describe 'and an object was not given' do

          it 'should use the default value' do
            expect(Formtastic::FormBuilder.all_fields_required_by_default).to eq(true)
            Formtastic::FormBuilder.all_fields_required_by_default = false

            concat(semantic_form_for(:project, :url => 'http://test.host/') do |builder|
              concat(builder.input(:title))
            end)
            expect(output_buffer.to_str).not_to have_tag('form li.required')
            expect(output_buffer.to_str).to have_tag('form li.optional')

            Formtastic::FormBuilder.all_fields_required_by_default = true
          end

        end

        describe 'and an object with :validators_on was given (ActiveModel, Active Resource)' do
          before do
            allow(@new_post).to receive(:class).and_return(::PostModel)
          end

          after do
            allow(@new_post).to receive(:class).and_return(::Post)
          end
          describe 'and validates_presence_of was called for the method' do
            it 'should be required' do

              expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                         active_model_presence_validator([:title])
                                                                                                     ])

              expect(@new_post.class).to receive(:validators_on).with(:body).at_least(:once).and_return([
                                                                                                        active_model_presence_validator([:body], {:if => true})
                                                                                                    ])

              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
                concat(builder.input(:body))
              end)
              expect(output_buffer.to_str).to have_tag('form li.required')
              expect(output_buffer.to_str).not_to have_tag('form li.optional')
            end

            it 'should be required when there is :on => :create option on create' do
              with_config :required_string, " required yo!" do
                expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                           active_model_presence_validator([:title], {:on => :create})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                expect(output_buffer.to_str).to have_tag('form li.required')
                expect(output_buffer.to_str).not_to have_tag('form li.optional')
              end
            end

            it 'should be required when there is :create option in validation contexts array on create' do
              with_config :required_string, " required yo!" do
                expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                           active_model_presence_validator([:title], {:on => [:create]})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                expect(output_buffer.to_str).to have_tag('form li.required')
                expect(output_buffer.to_str).not_to have_tag('form li.optional')
              end
            end

            it 'should be required when there is :on => :save option on create' do
              with_config :required_string, " required yo!" do
                expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                           active_model_presence_validator([:title], {:on => :save})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                expect(output_buffer.to_str).to have_tag('form li.required')
                expect(output_buffer.to_str).not_to have_tag('form li.optional')
              end
            end

            it 'should be required when there is :save option in validation contexts array on create' do
              with_config :required_string, " required yo!" do
                expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                           active_model_presence_validator([:title], {:on => [:save]})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                expect(output_buffer.to_str).to have_tag('form li.required')
                expect(output_buffer.to_str).not_to have_tag('form li.optional')
              end
            end

            it 'should be required when there is :on => :save option on update' do
              with_config :required_string, " required yo!" do
                expect(@fred.class).to receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                       active_model_presence_validator([:login], {:on => :save})
                                                                                                   ])
                concat(semantic_form_for(@fred) do |builder|
                  concat(builder.input(:login))
                end)
                expect(output_buffer.to_str).to have_tag('form li.required')
                expect(output_buffer.to_str).not_to have_tag('form li.optional')
              end
            end

            it 'should be required when there is :save option in validation contexts array on update' do
              with_config :required_string, " required yo!" do
                expect(@fred.class).to receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                       active_model_presence_validator([:login], {:on => [:save]})
                                                                                                   ])
                concat(semantic_form_for(@fred) do |builder|
                  concat(builder.input(:login))
                end)
                expect(output_buffer.to_str).to have_tag('form li.required')
                expect(output_buffer.to_str).not_to have_tag('form li.optional')
              end
            end

            it 'should not be required when there is :on => :create option on update' do
              expect(@fred.class).to receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                     active_model_presence_validator([:login], {:on => :create})
                                                                                                 ])
              concat(semantic_form_for(@fred) do |builder|
                concat(builder.input(:login))
              end)
              expect(output_buffer.to_str).not_to have_tag('form li.required')
              expect(output_buffer.to_str).to have_tag('form li.optional')
            end

            it 'should not be required when there is :create option in validation contexts array on update' do
              expect(@fred.class).to receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                     active_model_presence_validator([:login], {:on => [:create]})
                                                                                                 ])
              concat(semantic_form_for(@fred) do |builder|
                concat(builder.input(:login))
              end)
              expect(output_buffer.to_str).not_to have_tag('form li.required')
              expect(output_buffer.to_str).to have_tag('form li.optional')
            end

            it 'should not be required when there is :on => :update option on create' do
              expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                         active_model_presence_validator([:title], {:on => :update})
                                                                                                     ])
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              expect(output_buffer.to_str).not_to have_tag('form li.required')
              expect(output_buffer.to_str).to have_tag('form li.optional')
            end

            it 'should not be required when there is :update option in validation contexts array on create' do
              expect(@new_post.class).to receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                         active_model_presence_validator([:title], {:on => [:update]})
                                                                                                     ])
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              expect(output_buffer.to_str).not_to have_tag('form li.required')
              expect(output_buffer.to_str).to have_tag('form li.optional')
            end

            it 'should be not be required if the optional :if condition is not satisifed' do
              presence_should_be_required(:required => false, :tag => :body, :options => { :if => false })
            end

            it 'should not be required if the optional :if proc evaluates to false' do
              presence_should_be_required(:required => false, :tag => :body, :options => { :if => proc { |record| false } })
            end

            it 'should be required if the optional :if proc evaluates to true' do
              presence_should_be_required(:required => true, :tag => :body, :options => { :if => proc { |record| true } })
            end

            it 'should not be required if the optional :unless proc evaluates to true' do
              presence_should_be_required(:required => false, :tag => :body, :options => { :unless => proc { |record| true } })
            end

            it 'should be required if the optional :unless proc evaluates to false' do
              presence_should_be_required(:required => true, :tag => :body, :options => { :unless => proc { |record| false } })
            end

            it 'should be required if the optional :if with a method string evaluates to true' do
              expect(@new_post).to receive(:required_condition).and_return(true)
              presence_should_be_required(:required => true, :tag => :body, :options => { :if => :required_condition })
            end

            it 'should be required if the optional :if with a method string evaluates to false' do
              expect(@new_post).to receive(:required_condition).and_return(false)
              presence_should_be_required(:required => false, :tag => :body, :options => { :if => :required_condition })
            end

            it 'should be required if the optional :unless with a method string evaluates to false' do
              expect(@new_post).to receive(:required_condition).and_return(false)
              presence_should_be_required(:required => true, :tag => :body, :options => { :unless => :required_condition })
            end

            it 'should not be required if the optional :unless with a method string evaluates to true' do
              expect(@new_post).to receive(:required_condition).and_return(true)
              presence_should_be_required(:required => false, :tag => :body, :options => { :unless => :required_condition })
            end
          end

          describe 'and validates_inclusion_of was called for the method' do
            it 'should be required' do
              expect(@new_post.class).to receive(:validators_on).with(:published).at_least(:once).and_return([
                                                                                                             active_model_inclusion_validator([:published], {:in => [false, true]})
                                                                                                         ])
              should_be_required(:tag => :published, :required => true)
            end

            it 'should not be required if allow_blank is true' do
              expect(@new_post.class).to receive(:validators_on).with(:published).at_least(:once).and_return([
                                                                                                             active_model_inclusion_validator([:published], {:in => [false, true], :allow_blank => true})
                                                                                                         ])
              should_be_required(:tag => :published, :required => false)
            end
          end

          describe 'and validates_length_of was called for the method' do
            it 'should be required if minimum is set' do
              length_should_be_required(:tag => :title, :required => true, :options => {:minimum => 1})
            end

            it 'should be required if :within is set' do
              length_should_be_required(:tag => :title, :required => true, :options => {:within => 1..5})
            end

            it 'should not be required if :within allows zero length' do
              length_should_be_required(:tag => :title, :required => false, :options => {:within => 0..5})
            end

            it 'should not be required if only :minimum is zero' do
              length_should_be_required(:tag => :title, :required => false, :options => {:minimum => 0})
            end

            it 'should not be required if only :minimum is not set' do
              length_should_be_required(:tag => :title, :required => false, :options => {:maximum => 5})
            end

            it 'should not be required if allow_blank is true' do
              length_should_be_required(:tag => :published, :required => false, :options => {:allow_blank => true})
            end
          end

          def add_presence_validator(options)
            allow(@new_post.class).to receive(:validators_on).with(options[:tag]).and_return([
                                                                                    active_model_presence_validator([options[:tag]], options[:options])
                                                                                ])
          end

          def add_length_validator(options)
            expect(@new_post.class).to receive(:validators_on).with(options[:tag]).at_least(:once) {[
                active_model_length_validator([options[:tag]], options[:options])
            ]}
          end

          # TODO make a matcher for this?
          def should_be_required(options)
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(options[:tag]))
            end)

            if options[:required]
              expect(output_buffer.to_str).not_to have_tag('form li.optional')
              expect(output_buffer.to_str).to have_tag('form li.required')
            else
              expect(output_buffer.to_str).to have_tag('form li.optional')
              expect(output_buffer.to_str).not_to have_tag('form li.required')
            end
          end

          def presence_should_be_required(options)
            add_presence_validator(options)
            should_be_required(options)
          end

          def length_should_be_required(options)
            add_length_validator(options)
            should_be_required(options)
          end

          # TODO JF reversed this during refactor, need to make sure
          describe 'and there are no requirement validations on the method' do
            before do
              expect(@new_post.class).to receive(:validators_on).with(:title).and_return([])
            end

            it 'should not be required' do
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              expect(output_buffer.to_str).not_to have_tag('form li.required')
              expect(output_buffer.to_str).to have_tag('form li.optional')
            end
          end

        end

        describe 'and an object without :validators_on' do

          it 'should use the default value' do
            expect(Formtastic::FormBuilder.all_fields_required_by_default).to eq(true)
            Formtastic::FormBuilder.all_fields_required_by_default = false

            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title))
            end)
            expect(output_buffer.to_str).not_to have_tag('form li.required')
            expect(output_buffer.to_str).to have_tag('form li.optional')

            Formtastic::FormBuilder.all_fields_required_by_default = true
          end

        end

      end

    end

    describe ':as option' do

      describe 'when not provided' do

        it 'should default to a string for forms without objects unless column is password' do
          concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.input(:anything))
          end)
          expect(output_buffer.to_str).to have_tag('form li.string')
        end

        it 'should default to password for forms without objects if column is password' do
          concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.input(:password))
            concat(builder.input(:password_confirmation))
            concat(builder.input(:confirm_password))
          end)
          expect(output_buffer.to_str).to have_tag('form li.password', :count => 3)
        end

        it 'should default to a string for methods on objects that don\'t respond to "column_for_attribute"' do
          allow(@new_post).to receive(:method_without_a_database_column)
          allow(@new_post).to receive(:column_for_attribute).and_return(nil)
          expect(default_input_type(nil, :method_without_a_database_column)).to eq(:string)
        end

        it 'should default to :password for methods that don\'t have a column in the database but "password" is in the method name' do
          allow(@new_post).to receive(:password_method_without_a_database_column)
          allow(@new_post).to receive(:column_for_attribute).and_return(nil)
          expect(default_input_type(nil, :password_method_without_a_database_column)).to eq(:password)
        end

        it 'should default to :password for methods on objects that don\'t respond to "column_for_attribute" but "password" is in the method name' do
          allow(@new_post).to receive(:password_method_without_a_database_column)
          allow(@new_post).to receive(:column_for_attribute).and_return(nil)
          expect(default_input_type(nil, :password_method_without_a_database_column)).to eq(:password)
        end

        it 'should default to :number for "integer" column with name ending in "_id"' do
          allow(@new_post).to receive(:aws_instance_id)
          allow(@new_post).to receive(:column_for_attribute).with(:aws_instance_id).and_return(double('column', :type => :integer))
          expect(default_input_type(:integer, :aws_instance_id)).to eq(:number)
        end

        it 'should default to :select for associations' do
          allow(@new_post.class).to receive(:reflect_on_association).with(:user_id).and_return(double('ActiveRecord::Reflection::AssociationReflection'))
          allow(@new_post.class).to receive(:reflect_on_association).with(:section_id).and_return(double('ActiveRecord::Reflection::AssociationReflection'))
          expect(default_input_type(:integer, :user_id)).to eq(:select)
          expect(default_input_type(:integer, :section_id)).to eq(:select)
        end

        it 'should default to :select for enum' do
          statuses = ActiveSupport::HashWithIndifferentAccess.new("active"=>0, "inactive"=>1)
          allow(@new_post.class).to receive(:statuses) { statuses }
          allow(@new_post).to receive(:defined_enums) { {"status" => statuses } }

          expect(default_input_type(:integer, :status)).to eq(:select)
        end

        it 'should default to :password for :string column types with "password" in the method name' do
          expect(default_input_type(:string, :password)).to eq(:password)
          expect(default_input_type(:string, :hashed_password)).to eq(:password)
          expect(default_input_type(:string, :password_hash)).to eq(:password)
        end

        it 'should default to :text for :text column types' do
          expect(default_input_type(:text)).to eq(:text)
        end

        it 'should default to :date_select for :date column types' do
          expect(default_input_type(:date)).to eq(:date_select)
        end

        it 'should default to :text for :hstore, :json and :jsonb column types' do
          expect(default_input_type(:hstore)).to eq(:text)
          expect(default_input_type(:json)).to eq(:text)
          expect(default_input_type(:jsonb)).to eq(:text)
        end

        it 'should default to :datetime_select for :datetime and :timestamp column types' do
          expect(default_input_type(:datetime)).to eq(:datetime_select)
          expect(default_input_type(:timestamp)).to eq(:datetime_select)
        end

        it 'should default to :time_select for :time column types' do
          expect(default_input_type(:time)).to eq(:time_select)
        end

        it 'should default to :boolean for :boolean column types' do
          expect(default_input_type(:boolean)).to eq(:boolean)
        end

        it 'should default to :string for :string column types' do
          expect(default_input_type(:string)).to eq(:string)
        end

        it 'should default to :string for :citext column types' do
          expect(default_input_type(:citext)).to eq(:string)
        end

        it 'should default to :string for :inet column types' do
          expect(default_input_type(:inet)).to eq(:string)
        end

        it 'should default to :number for :integer, :float and :decimal column types' do
          expect(default_input_type(:integer)).to eq(:number)
          expect(default_input_type(:float)).to eq(:number)
          expect(default_input_type(:decimal)).to eq(:number)
        end

        it 'should default to :country for :string columns named country' do
          expect(default_input_type(:string, :country)).to eq(:country)
        end

        it 'should default to :email for :string columns matching email' do
          expect(default_input_type(:string, :email)).to eq(:email)
          expect(default_input_type(:string, :customer_email)).to eq(:email)
          expect(default_input_type(:string, :email_work)).to eq(:email)
        end

        it 'should default to :url for :string columns named url or website' do
          expect(default_input_type(:string, :url)).to eq(:url)
          expect(default_input_type(:string, :website)).to eq(:url)
          expect(default_input_type(:string, :my_url)).to eq(:url)
          expect(default_input_type(:string, :hurl)).not_to eq(:url)
        end

        it 'should default to :phone for :string columns named phone or fax' do
          expect(default_input_type(:string, :phone)).to eq(:phone)
          expect(default_input_type(:string, :fax)).to eq(:phone)
        end

        it 'should default to :search for :string columns named search' do
          expect(default_input_type(:string, :search)).to eq(:search)
        end

        it 'should default to :color for :string columns matching color' do
          expect(default_input_type(:string, :color)).to eq(:color)
          expect(default_input_type(:string, :user_color)).to eq(:color)
          expect(default_input_type(:string, :color_for_image)).to eq(:color)
        end

        describe 'defaulting to file column' do
          Formtastic::FormBuilder.file_methods.each do |method|
            it "should default to :file for attributes that respond to ##{method}" do
              column = double('column')

              Formtastic::FormBuilder.file_methods.each do |test|
                ### TODO: Check if this is ok
                allow(column).to receive(method).with(test).and_return(method == test)
              end

              expect(@new_post).to receive(method).and_return(column)

              semantic_form_for(@new_post) do |builder|
                expect(builder.send(:default_input_type, method)).to eq(:file)
              end
            end
          end

        end
      end

      it 'should call the corresponding input class with .to_html' do
        [:select, :time_zone, :radio, :date_select, :datetime_select, :time_select, :boolean, :check_boxes, :hidden, :string, :password, :number, :text, :file].each do |input_style|
          allow(@new_post).to receive(:generic_column_name)
          allow(@new_post).to receive(:column_for_attribute).and_return(double('column', :type => :string, :limit => 255))
          semantic_form_for(@new_post) do |builder|
            input_instance = double('Input instance')
            input_class = "#{input_style.to_s}_input".classify
            input_constant = "Formtastic::Inputs::#{input_class}".constantize

            expect(input_constant).to receive(:new).and_return(input_instance)
            expect(input_instance).to receive(:to_html).and_return("some HTML")

            concat(builder.input(:generic_column_name, :as => input_style))
          end
        end
      end

    end

    describe ':label option' do

      describe 'when provided' do
        it 'should be passed down to the label tag' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => "Kustom"))
          end)
          expect(output_buffer.to_str).to have_tag("form li label", :text => /Kustom/)
        end

        it 'should not generate a label if false' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => false))
          end)
          expect(output_buffer.to_str).not_to have_tag("form li label")
        end

        it 'should be dupped if frozen' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => "Kustom".freeze))
          end)
          expect(output_buffer.to_str).to have_tag("form li label", :text => /Kustom/)
        end
      end

      describe 'when not provided' do
        describe 'when localized label is provided' do
          describe 'and object is given' do
            describe 'and label_str_method not :humanize' do
              it 'should render a label with localized text and not apply the label_str_method' do
                with_config :label_str_method, :reverse do
                  @localized_label_text = 'Localized title'
                  allow(@new_post).to receive(:meta_description)
                  ::I18n.backend.store_translations :en,
                                                    :formtastic => {
                                                        :labels => {
                                                            :meta_description => @localized_label_text
                                                        }
                                                    }

                  concat(semantic_form_for(@new_post) do |builder|
                    concat(builder.input(:meta_description))
                  end)
                  expect(output_buffer.to_str).to have_tag('form li label', :text => /Localized title/)
                end
              end
            end
          end
        end

        describe 'when localized label is NOT provided' do
          describe 'and object is not given' do
            it 'should default the humanized method name, passing it down to the label tag' do
              ::I18n.backend.store_translations :en, :formtastic => {}
              with_config :label_str_method, :humanize do
                concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
                  concat(builder.input(:meta_description))
                end)
                expect(output_buffer.to_str).to have_tag("form li label", :text => /#{'meta_description'.humanize}/)
              end
            end
          end

          describe 'and object is given' do
            it 'should delegate the label logic to class human attribute name and pass it down to the label tag' do
              allow(@new_post).to receive(:meta_description) # a two word method name
              expect(@new_post.class).to receive(:human_attribute_name).with('meta_description').and_return('meta_description'.humanize)

              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:meta_description))
              end)
              expect(output_buffer.to_str).to have_tag("form li label", :text => /#{'meta_description'.humanize}/)
            end
          end

          describe 'and object is given with label_str_method set to :capitalize' do
            it 'should capitalize method name, passing it down to the label tag' do
              with_config :label_str_method, :capitalize do
                allow(@new_post).to receive(:meta_description)

                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:meta_description))
                end)
                expect(output_buffer.to_str).to have_tag("form li label", :text => /#{'meta_description'.capitalize}/)
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
          end

          it 'should render a label with localized label (I18n)' do
            with_config :i18n_lookups_by_default, false do
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :label => true))
                concat(builder.input(:published, :as => :boolean, :label => true))
              end)
              expect(output_buffer.to_str).to have_tag('form li label', :text => Regexp.new('^' + @localized_label_text))
            end
          end

          it 'should render a hint paragraph containing an optional localized label (I18n) if first is not set' do
            with_config :i18n_lookups_by_default, false do
              ::I18n.backend.store_translations :en,
                                                :formtastic => {
                                                    :labels => {
                                                        :post => {
                                                            :title => nil,
                                                            :published => nil
                                                        }
                                                    }
                                                }
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :label => true))
                concat(builder.input(:published, :as => :boolean, :label => true))
              end)
              expect(output_buffer.to_str).to have_tag('form li label', :text => Regexp.new('^' + @default_localized_label_text))
            end
          end
        end
      end

    end

    describe ':label_method option' do
      it "should allow label_html to add custom attributes" do
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:title, :label_html => { :data => { :tooltip => 'Great Tooltip' } }))
        end)
        aggregate_failures do
          expect(output_buffer.to_str).to have_tag('form li label[data-tooltip="Great Tooltip"]')
        end
      end
    end

    describe ':hint option' do

      describe 'when provided' do

        after do
          Formtastic::FormBuilder.default_hint_class = "inline-hints"
        end

        it 'should be passed down to the paragraph tag' do
          hint_text = "this is the title of the post"
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :hint => hint_text))
          end)
          expect(output_buffer.to_str).to have_tag("form li p.inline-hints", :text => hint_text)
        end

        it 'should have a custom hint class defaulted for all forms' do
          hint_text = "this is the title of the post"
          Formtastic::FormBuilder.default_hint_class = "custom-hint-class"
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :hint => hint_text))
          end)
          expect(output_buffer.to_str).to have_tag("form li p.custom-hint-class", :text => hint_text)
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
                                                  }
                                              }
          end

          after do
            ::I18n.backend.reload!
          end

          describe 'when provided value (hint value) is set to TRUE' do
            it 'should render a hint paragraph containing a localized hint (I18n)' do
              with_config :i18n_lookups_by_default, false do
                ::I18n.backend.store_translations :en,
                                                  :formtastic => {
                                                      :hints => {
                                                          :post => {
                                                              :title => @localized_hint_text
                                                          }
                                                      }
                                                  }
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title, :hint => true))
                end)
                expect(output_buffer.to_str).to have_tag('form li p.inline-hints', :text => @localized_hint_text)
              end
            end

            it 'should render a hint paragraph containing an optional localized hint (I18n) if first is not set' do
              with_config :i18n_lookups_by_default, false do
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title, :hint => true))
                end)
                expect(output_buffer.to_str).to have_tag('form li p.inline-hints', :text => @default_localized_hint_text)
              end
            end
          end

          describe 'when provided value (label value) is set to FALSE' do
            it 'should not render a hint paragraph' do
              with_config :i18n_lookups_by_default, false do
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title, :hint => false))
                end)
                expect(output_buffer.to_str).not_to have_tag('form li p.inline-hints', :text => @localized_hint_text)
              end
            end
          end
        end

        describe 'when localized hint (I18n) is a model with attribute hints' do
          it "should see the provided hash as a blank entry" do
            with_config :i18n_lookups_by_default, false do
              ::I18n.backend.store_translations :en,
                                                :formtastic => {
                                                    :hints => {
                                                        :title => { # movie title
                                                                    :summary => @localized_hint_text # summary of movie
                                                        }
                                                    }
                                                }
              semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :hint => true))
              end
              expect(output_buffer.to_str).not_to have_tag('form li p.inline-hints', :text => @localized_hint_text)
            end
          end
        end

        describe 'when localized hint (I18n) is not provided' do
          it 'should not render a hint paragraph' do
            with_config :i18n_lookups_by_default, false do
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              expect(output_buffer.to_str).not_to have_tag('form li p.inline-hints')
            end
          end
        end
      end

    end

    describe ':wrapper_html option' do

      describe 'when provided' do
        it 'should be passed down to the li tag' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:id => :another_id}))
          end)
          expect(output_buffer.to_str).to have_tag("form li#another_id")
        end

        it 'should append given classes to li default classes' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:class => :another_class}, :required => true))
          end)
          expect(output_buffer.to_str).to have_tag("form li.string")
          expect(output_buffer.to_str).to have_tag("form li.required")
          expect(output_buffer.to_str).to have_tag("form li.another_class")
        end

        it 'should allow classes to be an array' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:class => [ :my_class, :another_class ]}))
          end)
          expect(output_buffer.to_str).to have_tag("form li.string")
          expect(output_buffer.to_str).to have_tag("form li.my_class")
          expect(output_buffer.to_str).to have_tag("form li.another_class")
        end

        describe 'when nil' do
          it 'should not put an id attribute on the div tag' do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :wrapper_html => {:id => nil}))
            end)
            expect(output_buffer.to_str).to have_tag('form li:not([id])')
          end
        end
      end

      describe 'when not provided' do
        it 'should use default id and class' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title))
          end)
          expect(output_buffer.to_str).to have_tag("form li#post_title_input")
          expect(output_buffer.to_str).to have_tag("form li.string")
        end
      end

    end

    describe ':collection option' do

      it "should be required on polymorphic associations" do
        allow(@new_post).to receive(:commentable)
        allow(@new_post.class).to receive(:reflections).and_return({
                                                          :commentable => double('macro_reflection', :options => { :polymorphic => true }, :macro => :belongs_to)
                                                      })
        allow(@new_post).to receive(:column_for_attribute).with(:commentable).and_return(
            double('column', :type => :integer)
        )
        allow(@new_post.class).to receive(:reflect_on_association).with(:commentable).and_return(
            double('reflection', :macro => :belongs_to, :options => { :polymorphic => true })
        )
        expect {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.inputs do
              concat(builder.input :commentable)
            end)
          end)
        }.to raise_error(Formtastic::PolymorphicInputWithoutCollectionError)
      end

    end

  end

  describe 'options re-use' do

    it 'should retain :as option when re-using the same options hash' do
      my_options = { :as => :string }
      output = ''

      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:title, my_options))
        concat(builder.input(:publish_at, my_options))
      end)
      expect(output_buffer.to_str).to have_tag 'li.string', :count => 2
    end
  end

  describe 'instantiating an input class' do
    context 'when a class does not exist' do
      it "should raise an error" do
        expect {
          concat(semantic_form_for(@new_post) do |builder|
            builder.input(:title, :as => :non_existant)
          end)
        }.to raise_error(Formtastic::UnknownInputError)
      end
    end

    context 'when a customized top-level class does not exist' do

      it 'should instantiate the Formtastic input' do
        input = double('input', :to_html => 'some HTML')
        expect(Formtastic::Inputs::StringInput).to receive(:new).and_return(input)
        concat(semantic_form_for(@new_post) do |builder|
          builder.input(:title, :as => :string)
        end)
      end

    end

    describe 'when a top-level input class exists' do
      it "should instantiate the top-level input instead of the Formtastic one" do
        class ::StringInput < Formtastic::Inputs::StringInput
        end

        input = double('input', :to_html => 'some HTML')
        expect(Formtastic::Inputs::StringInput).not_to receive(:new)
        expect(::StringInput).to receive(:new).and_return(input)

        concat(semantic_form_for(@new_post) do |builder|
          builder.input(:title, :as => :string)
        end)
      end
    end


  end
end
