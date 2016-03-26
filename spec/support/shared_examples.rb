RSpec.shared_context 'form builder' do
  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  after do
    ::I18n.backend.reload!
  end
end

# TODO: move this back to spec/helpers/action_helper_spec.rb in Formtastic 4.0
RSpec.shared_examples 'Action Helper' do
  include_context 'form builder'

  describe 'arguments and options' do

    it 'should require the first argument (the action method)' do
      lambda {
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.action()) # no args passed in at all
        end)
      }.should raise_error(ArgumentError)
    end

    describe ':as option' do

      describe 'when not provided' do

        it 'should default to a commit for commit' do
          concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.action(:submit))
          end)
          output_buffer.should have_tag('form li.action.input_action', :count => 1)
        end

        it 'should default to a button for reset' do
          concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.action(:reset))
          end)
          output_buffer.should have_tag('form li.action.input_action', :count => 1)
        end

        it 'should default to a link for cancel' do
          concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.action(:cancel))
          end)
          output_buffer.should have_tag('form li.action.link_action', :count => 1)
        end
      end

      it 'should call the corresponding action class with .to_html' do
        [:input, :button, :link].each do |action_style|
          semantic_form_for(:project, :url => "http://test.host") do |builder|
            action_instance = double('Action instance')
            action_class = "#{action_style.to_s}_action".classify
            action_constant = "Formtastic::Actions::#{action_class}".constantize

            action_constant.should_receive(:new).and_return(action_instance)
            action_instance.should_receive(:to_html).and_return("some HTML")

            concat(builder.action(:submit, :as => action_style))
          end
        end
      end

    end

    #describe ':label option' do
    #
    #  describe 'when provided' do
    #    it 'should be passed down to the label tag' do
    #      concat(semantic_form_for(@new_post) do |builder|
    #        concat(builder.input(:title, :label => "Kustom"))
    #      end)
    #      output_buffer.should have_tag("form li label", /Kustom/)
    #    end
    #
    #    it 'should not generate a label if false' do
    #      concat(semantic_form_for(@new_post) do |builder|
    #        concat(builder.input(:title, :label => false))
    #      end)
    #      output_buffer.should_not have_tag("form li label")
    #    end
    #
    #    it 'should be dupped if frozen' do
    #      concat(semantic_form_for(@new_post) do |builder|
    #        concat(builder.input(:title, :label => "Kustom".freeze))
    #      end)
    #      output_buffer.should have_tag("form li label", /Kustom/)
    #    end
    #  end
    #
    #  describe 'when not provided' do
    #    describe 'when localized label is provided' do
    #      describe 'and object is given' do
    #        describe 'and label_str_method not :humanize' do
    #          it 'should render a label with localized text and not apply the label_str_method' do
    #            with_config :label_str_method, :reverse do
    #              @localized_label_text = 'Localized title'
    #              @new_post.stub(:meta_description)
    #              ::I18n.backend.store_translations :en,
    #                :formtastic => {
    #                  :labels => {
    #                    :meta_description => @localized_label_text
    #                  }
    #                }
    #
    #              concat(semantic_form_for(@new_post) do |builder|
    #                concat(builder.input(:meta_description))
    #              end)
    #              output_buffer.should have_tag('form li label', /Localized title/)
    #            end
    #          end
    #        end
    #      end
    #    end
    #
    #    describe 'when localized label is NOT provided' do
    #      describe 'and object is not given' do
    #        it 'should default the humanized method name, passing it down to the label tag' do
    #          ::I18n.backend.store_translations :en, :formtastic => {}
    #          with_config :label_str_method, :humanize do
    #            concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
    #              concat(builder.input(:meta_description))
    #            end)
    #            output_buffer.should have_tag("form li label", /#{'meta_description'.humanize}/)
    #          end
    #        end
    #      end
    #
    #      describe 'and object is given' do
    #        it 'should delegate the label logic to class human attribute name and pass it down to the label tag' do
    #          @new_post.stub(:meta_description) # a two word method name
    #          @new_post.class.should_receive(:human_attribute_name).with('meta_description').and_return('meta_description'.humanize)
    #
    #          concat(semantic_form_for(@new_post) do |builder|
    #            concat(builder.input(:meta_description))
    #          end)
    #          output_buffer.should have_tag("form li label", /#{'meta_description'.humanize}/)
    #        end
    #      end
    #
    #      describe 'and object is given with label_str_method set to :capitalize' do
    #        it 'should capitalize method name, passing it down to the label tag' do
    #          with_config :label_str_method, :capitalize do
    #            @new_post.stub(:meta_description)
    #
    #            concat(semantic_form_for(@new_post) do |builder|
    #              concat(builder.input(:meta_description))
    #            end)
    #            output_buffer.should have_tag("form li label", /#{'meta_description'.capitalize}/)
    #          end
    #        end
    #      end
    #    end
    #
    #    describe 'when localized label is provided' do
    #      before do
    #        @localized_label_text = 'Localized title'
    #        @default_localized_label_text = 'Default localized title'
    #        ::I18n.backend.store_translations :en,
    #          :formtastic => {
    #              :labels => {
    #                :title => @default_localized_label_text,
    #                :published => @default_localized_label_text,
    #                :post => {
    #                  :title => @localized_label_text,
    #                  :published => @default_localized_label_text
    #                 }
    #               }
    #            }
    #      end
    #
    #      it 'should render a label with localized label (I18n)' do
    #        with_config :i18n_lookups_by_default, false do
    #          concat(semantic_form_for(@new_post) do |builder|
    #            concat(builder.input(:title, :label => true))
    #            concat(builder.input(:published, :as => :boolean, :label => true))
    #          end)
    #          output_buffer.should have_tag('form li label', Regexp.new('^' + @localized_label_text))
    #        end
    #      end
    #
    #      it 'should render a hint paragraph containing an optional localized label (I18n) if first is not set' do
    #        with_config :i18n_lookups_by_default, false do
    #          ::I18n.backend.store_translations :en,
    #            :formtastic => {
    #                :labels => {
    #                  :post => {
    #                    :title => nil,
    #                    :published => nil
    #                   }
    #                 }
    #              }
    #          concat(semantic_form_for(@new_post) do |builder|
    #            concat(builder.input(:title, :label => true))
    #            concat(builder.input(:published, :as => :boolean, :label => true))
    #          end)
    #          output_buffer.should have_tag('form li label', Regexp.new('^' + @default_localized_label_text))
    #        end
    #      end
    #    end
    #  end
    #
    #end
    #
    describe ':wrapper_html option' do

      describe 'when provided' do
        it 'should be passed down to the li tag' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:submit, :wrapper_html => {:id => :another_id}))
          end)
          output_buffer.should have_tag("form li#another_id")
        end

        it 'should append given classes to li default classes' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:submit, :wrapper_html => {:class => :another_class}))
          end)
          output_buffer.should have_tag("form li.action")
          output_buffer.should have_tag("form li.input_action")
          output_buffer.should have_tag("form li.another_class")
        end

        it 'should allow classes to be an array' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:submit, :wrapper_html => {:class => [ :my_class, :another_class ]}))
          end)
          output_buffer.should have_tag("form li.action")
          output_buffer.should have_tag("form li.input_action")
          output_buffer.should have_tag("form li.my_class")
          output_buffer.should have_tag("form li.another_class")
        end
      end

      describe 'when not provided' do
        it 'should use default id and class' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:submit))
          end)
          output_buffer.should have_tag("form li#post_submit_action")
          output_buffer.should have_tag("form li.action")
          output_buffer.should have_tag("form li.input_action")
        end
      end

    end

  end

  describe 'instantiating an action class' do
    context 'when a class does not exist' do
      it "should raise an error" do
        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            builder.action(:submit, :as => :non_existant)
          end)
        }.should raise_error(Formtastic::UnknownActionError)
      end
    end

    context 'when a customized top-level class does not exist' do
      it 'should instantiate the Formtastic action' do
        action = double('action', :to_html => 'some HTML')
        Formtastic::Actions::ButtonAction.should_receive(:new).and_return(action)
        concat(semantic_form_for(@new_post) do |builder|
          builder.action(:commit, :as => :button)
        end)
      end
    end

    describe 'when a top-level (custom) action class exists' do
      it "should instantiate the top-level action instead of the Formtastic one" do
        class ::ButtonAction < Formtastic::Actions::ButtonAction
        end

        action = double('action', :to_html => 'some HTML')
        Formtastic::Actions::ButtonAction.should_not_receive(:new)
        ::ButtonAction.should_receive(:new).and_return(action)

        concat(semantic_form_for(@new_post) do |builder|
          builder.action(:commit, :as => :button)
        end)
      end
    end

    describe 'support for :as on each action' do

      it "should raise an error when the action does not support the :as" do
        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:submit, :as => :link))
          end)
        }.should raise_error(Formtastic::UnsupportedMethodForAction)

        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:cancel, :as => :input))
          end)
        }.should raise_error(Formtastic::UnsupportedMethodForAction)

        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:cancel, :as => :button))
          end)
        }.should raise_error(Formtastic::UnsupportedMethodForAction)
      end

      it "should not raise an error when the action does not support the :as" do
        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:cancel, :as => :link))
          end)
        }.should_not raise_error

        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:submit, :as => :input))
          end)
        }.should_not raise_error

        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:submit, :as => :button))
          end)
        }.should_not raise_error

        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:reset, :as => :input))
          end)
        }.should_not raise_error

        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.action(:reset, :as => :button))
          end)
        }.should_not raise_error
      end

    end

  end

end

# TODO: move this back to spec/helpers/input_helper_spec.rb in Formtastic 4.0
RSpec.shared_examples 'Input Helper' do
  include_context 'form builder'

  before do
    @errors = double('errors')
    @errors.stub(:[]).and_return([])
    @new_post.stub(:errors).and_return(@errors)
  end

  describe 'arguments and options' do

    it 'should require the first argument (the method on form\'s object)' do
      lambda {
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input()) # no args passed in at all
        end)
      }.should raise_error(ArgumentError)
    end

    describe ':required option' do

      describe 'when true' do

        it 'should set a "required" class' do
          with_config :required_string, " required yo!" do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :required => true))
            end)
            output_buffer.should_not have_tag('form li.optional')
            output_buffer.should have_tag('form li.required')
          end
        end

        it 'should append the "required" string to the label' do
          with_config :required_string, " required yo!" do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :required => true))
            end)
            output_buffer.should have_tag('form li.required label', /required yo/)
          end
        end
      end

      describe 'when false' do

        before do
          @string = Formtastic::FormBuilder.optional_string = " optional yo!" # ensure there's something in the string
          @new_post.class.should_not_receive(:reflect_on_all_validations)
        end

        after do
          Formtastic::FormBuilder.optional_string = ''
        end

        it 'should set an "optional" class' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end)
          output_buffer.should_not have_tag('form li.required')
          output_buffer.should have_tag('form li.optional')
        end

        it 'should set and "optional" class also when there is presence validator' do
          @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                     active_model_presence_validator([:title])
                                                                                                 ])
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end)
          output_buffer.should_not have_tag('form li.required')
          output_buffer.should have_tag('form li.optional')
        end

        it 'should append the "optional" string to the label' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :required => false))
          end)
          output_buffer.should have_tag('form li.optional label', /#{@string}$/)
        end

      end

      describe 'when not provided' do

        describe 'and an object was not given' do

          it 'should use the default value' do
            Formtastic::FormBuilder.all_fields_required_by_default.should == true
            Formtastic::FormBuilder.all_fields_required_by_default = false

            concat(semantic_form_for(:project, :url => 'http://test.host/') do |builder|
              concat(builder.input(:title))
            end)
            output_buffer.should_not have_tag('form li.required')
            output_buffer.should have_tag('form li.optional')

            Formtastic::FormBuilder.all_fields_required_by_default = true
          end

        end

        describe 'and an object with :validators_on was given (ActiveModel, Active Resource)' do
          before do
            @new_post.stub(:class).and_return(::PostModel)
          end

          after do
            @new_post.stub(:class).and_return(::Post)
          end
          describe 'and validates_presence_of was called for the method' do
            it 'should be required' do

              @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                         active_model_presence_validator([:title])
                                                                                                     ])

              @new_post.class.should_receive(:validators_on).with(:body).at_least(:once).and_return([
                                                                                                        active_model_presence_validator([:body], {:if => true})
                                                                                                    ])

              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
                concat(builder.input(:body))
              end)
              output_buffer.should have_tag('form li.required')
              output_buffer.should_not have_tag('form li.optional')
            end

            it 'should be required when there is :on => :create option on create' do
              with_config :required_string, " required yo!" do
                @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                           active_model_presence_validator([:title], {:on => :create})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                output_buffer.should have_tag('form li.required')
                output_buffer.should_not have_tag('form li.optional')
              end
            end

            it 'should be required when there is :create option in validation contexts array on create' do
              with_config :required_string, " required yo!" do
                @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                         active_model_presence_validator([:title], {:on => [:create]})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                output_buffer.should have_tag('form li.required')
                output_buffer.should_not have_tag('form li.optional')
              end
            end

            it 'should be required when there is :on => :save option on create' do
              with_config :required_string, " required yo!" do
                @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                           active_model_presence_validator([:title], {:on => :save})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                output_buffer.should have_tag('form li.required')
                output_buffer.should_not have_tag('form li.optional')
              end
            end

            it 'should be required when there is :save option in validation contexts array on create' do
              with_config :required_string, " required yo!" do
                @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                         active_model_presence_validator([:title], {:on => [:save]})
                                                                                                       ])
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title))
                end)
                output_buffer.should have_tag('form li.required')
                output_buffer.should_not have_tag('form li.optional')
              end
            end

            it 'should be required when there is :on => :save option on update' do
              with_config :required_string, " required yo!" do
                @fred.class.should_receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                       active_model_presence_validator([:login], {:on => :save})
                                                                                                   ])
                concat(semantic_form_for(@fred) do |builder|
                  concat(builder.input(:login))
                end)
                output_buffer.should have_tag('form li.required')
                output_buffer.should_not have_tag('form li.optional')
              end
            end

            it 'should be required when there is :save option in validation contexts array on update' do
              with_config :required_string, " required yo!" do
                @fred.class.should_receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                     active_model_presence_validator([:login], {:on => [:save]})
                                                                                                   ])
                concat(semantic_form_for(@fred) do |builder|
                  concat(builder.input(:login))
                end)
                output_buffer.should have_tag('form li.required')
                output_buffer.should_not have_tag('form li.optional')
              end
            end

            it 'should not be required when there is :on => :create option on update' do
              @fred.class.should_receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                     active_model_presence_validator([:login], {:on => :create})
                                                                                                 ])
              concat(semantic_form_for(@fred) do |builder|
                concat(builder.input(:login))
              end)
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')
            end

            it 'should not be required when there is :create option in validation contexts array on update' do
              @fred.class.should_receive(:validators_on).with(:login).at_least(:once).and_return([
                                                                                                   active_model_presence_validator([:login], {:on => [:create]})
                                                                                                 ])
              concat(semantic_form_for(@fred) do |builder|
                concat(builder.input(:login))
              end)
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')
            end

            it 'should not be required when there is :on => :update option on create' do
              @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                         active_model_presence_validator([:title], {:on => :update})
                                                                                                     ])
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')
            end

            it 'should not be required when there is :update option in validation contexts array on create' do
              @new_post.class.should_receive(:validators_on).with(:title).at_least(:once).and_return([
                                                                                                       active_model_presence_validator([:title], {:on => [:update]})
                                                                                                     ])
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')
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
              @new_post.should_receive(:required_condition).and_return(true)
              presence_should_be_required(:required => true, :tag => :body, :options => { :if => :required_condition })
            end

            it 'should be required if the optional :if with a method string evaluates to false' do
              @new_post.should_receive(:required_condition).and_return(false)
              presence_should_be_required(:required => false, :tag => :body, :options => { :if => :required_condition })
            end

            it 'should be required if the optional :unless with a method string evaluates to false' do
              @new_post.should_receive(:required_condition).and_return(false)
              presence_should_be_required(:required => true, :tag => :body, :options => { :unless => :required_condition })
            end

            it 'should not be required if the optional :unless with a method string evaluates to true' do
              @new_post.should_receive(:required_condition).and_return(true)
              presence_should_be_required(:required => false, :tag => :body, :options => { :unless => :required_condition })
            end
          end

          describe 'and validates_inclusion_of was called for the method' do
            it 'should be required' do
              @new_post.class.should_receive(:validators_on).with(:published).at_least(:once).and_return([
                                                                                                             active_model_inclusion_validator([:published], {:in => [false, true]})
                                                                                                         ])
              should_be_required(:tag => :published, :required => true)
            end

            it 'should not be required if allow_blank is true' do
              @new_post.class.should_receive(:validators_on).with(:published).at_least(:once).and_return([
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
            @new_post.class.stub(:validators_on).with(options[:tag]).and_return([
                                                                                    active_model_presence_validator([options[:tag]], options[:options])
                                                                                ])
          end

          def add_length_validator(options)
            @new_post.class.should_receive(:validators_on).with(options[:tag]).at_least(:once) {[
                active_model_length_validator([options[:tag]], options[:options])
            ]}
          end

          # TODO make a matcher for this?
          def should_be_required(options)
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(options[:tag]))
            end)

            if options[:required]
              output_buffer.should_not have_tag('form li.optional')
              output_buffer.should have_tag('form li.required')
            else
              output_buffer.should have_tag('form li.optional')
              output_buffer.should_not have_tag('form li.required')
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
              @new_post.class.should_receive(:validators_on).with(:title).and_return([])
            end

            it 'should not be required' do
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              output_buffer.should_not have_tag('form li.required')
              output_buffer.should have_tag('form li.optional')
            end
          end

        end

        describe 'and an object without :validators_on' do

          it 'should use the default value' do
            Formtastic::FormBuilder.all_fields_required_by_default.should == true
            Formtastic::FormBuilder.all_fields_required_by_default = false

            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title))
            end)
            output_buffer.should_not have_tag('form li.required')
            output_buffer.should have_tag('form li.optional')

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
          output_buffer.should have_tag('form li.string')
        end

        it 'should default to password for forms without objects if column is password' do
          concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
            concat(builder.input(:password))
            concat(builder.input(:password_confirmation))
            concat(builder.input(:confirm_password))
          end)
          output_buffer.should have_tag('form li.password', :count => 3)
        end

        it 'should default to a string for methods on objects that don\'t respond to "column_for_attribute"' do
          @new_post.stub(:method_without_a_database_column)
          @new_post.stub(:column_for_attribute).and_return(nil)
          default_input_type(nil, :method_without_a_database_column).should == :string
        end

        it 'should default to :password for methods that don\'t have a column in the database but "password" is in the method name' do
          @new_post.stub(:password_method_without_a_database_column)
          @new_post.stub(:column_for_attribute).and_return(nil)
          default_input_type(nil, :password_method_without_a_database_column).should == :password
        end

        it 'should default to :password for methods on objects that don\'t respond to "column_for_attribute" but "password" is in the method name' do
          @new_post.stub(:password_method_without_a_database_column)
          @new_post.stub(:column_for_attribute).and_return(nil)
          default_input_type(nil, :password_method_without_a_database_column).should == :password
        end

        it 'should default to :number for "integer" column with name ending in "_id"' do
          @new_post.stub(:aws_instance_id)
          @new_post.stub(:column_for_attribute).with(:aws_instance_id).and_return(double('column', :type => :integer))
          default_input_type(:integer, :aws_instance_id).should == :number
        end

        it 'should default to :select for associations' do
          @new_post.class.stub(:reflect_on_association).with(:user_id).and_return(double('ActiveRecord::Reflection::AssociationReflection'))
          @new_post.class.stub(:reflect_on_association).with(:section_id).and_return(double('ActiveRecord::Reflection::AssociationReflection'))
          default_input_type(:integer, :user_id).should == :select
          default_input_type(:integer, :section_id).should == :select
        end

        it 'should default to :select for enum' do
          statuses = ActiveSupport::HashWithIndifferentAccess.new("active"=>0, "inactive"=>1)
          @new_post.class.stub(:statuses) { statuses }
          @new_post.stub(:defined_enums) { {"status" => statuses } }
          
          default_input_type(:integer, :status).should == :select
        end

        it 'should default to :password for :string column types with "password" in the method name' do
          default_input_type(:string, :password).should == :password
          default_input_type(:string, :hashed_password).should == :password
          default_input_type(:string, :password_hash).should == :password
        end

        it 'should default to :text for :text column types' do
          default_input_type(:text).should == :text
        end

        it 'should default to :date_select for :date column types' do
          default_input_type(:date).should == :date_select
        end

        it 'should default to :datetime_select for :datetime and :timestamp column types' do
          default_input_type(:datetime).should == :datetime_select
          default_input_type(:timestamp).should == :datetime_select
        end

        it 'should default to :time_select for :time column types' do
          default_input_type(:time).should == :time_select
        end

        it 'should default to :boolean for :boolean column types' do
          default_input_type(:boolean).should == :boolean
        end

        it 'should default to :string for :string column types' do
          default_input_type(:string).should == :string
        end

        it 'should default to :number for :integer, :float and :decimal column types' do
          default_input_type(:integer).should == :number
          default_input_type(:float).should == :number
          default_input_type(:decimal).should == :number
        end

        it 'should default to :country for :string columns named country' do
          default_input_type(:string, :country).should == :country
        end

        it 'should default to :email for :string columns matching email' do
          default_input_type(:string, :email).should == :email
          default_input_type(:string, :customer_email).should == :email
          default_input_type(:string, :email_work).should == :email
        end

        it 'should default to :url for :string columns named url or website' do
          default_input_type(:string, :url).should == :url
          default_input_type(:string, :website).should == :url
          default_input_type(:string, :my_url).should == :url
          default_input_type(:string, :hurl).should_not == :url
        end

        it 'should default to :phone for :string columns named phone or fax' do
          default_input_type(:string, :phone).should == :phone
          default_input_type(:string, :fax).should == :phone
        end

        it 'should default to :search for :string columns named search' do
          default_input_type(:string, :search).should == :search
        end

        it 'should default to :color for :string columns matching color' do
          default_input_type(:string, :color).should == :color
          default_input_type(:string, :user_color).should == :color
          default_input_type(:string, :color_for_image).should == :color
        end

        describe 'defaulting to file column' do
          Formtastic::FormBuilder.file_methods.each do |method|
            it "should default to :file for attributes that respond to ##{method}" do
              column = double('column')

              Formtastic::FormBuilder.file_methods.each do |test|
                ### TODO: Check if this is ok
                column.stub(method).with(test).and_return(method == test)
              end

              @new_post.should_receive(method).and_return(column)

              semantic_form_for(@new_post) do |builder|
                builder.send(:default_input_type, method).should == :file
              end
            end
          end

        end
      end

      it 'should call the corresponding input class with .to_html' do
        [:select, :time_zone, :radio, :date_select, :datetime_select, :time_select, :boolean, :check_boxes, :hidden, :string, :password, :number, :text, :file].each do |input_style|
          @new_post.stub(:generic_column_name)
          @new_post.stub(:column_for_attribute).and_return(double('column', :type => :string, :limit => 255))
          semantic_form_for(@new_post) do |builder|
            input_instance = double('Input instance')
            input_class = "#{input_style.to_s}_input".classify
            input_constant = "Formtastic::Inputs::#{input_class}".constantize

            input_constant.should_receive(:new).and_return(input_instance)
            input_instance.should_receive(:to_html).and_return("some HTML")

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
          output_buffer.should have_tag("form li label", /Kustom/)
        end

        it 'should not generate a label if false' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => false))
          end)
          output_buffer.should_not have_tag("form li label")
        end

        it 'should be dupped if frozen' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :label => "Kustom".freeze))
          end)
          output_buffer.should have_tag("form li label", /Kustom/)
        end
      end

      describe 'when not provided' do
        describe 'when localized label is provided' do
          describe 'and object is given' do
            describe 'and label_str_method not :humanize' do
              it 'should render a label with localized text and not apply the label_str_method' do
                with_config :label_str_method, :reverse do
                  @localized_label_text = 'Localized title'
                  @new_post.stub(:meta_description)
                  ::I18n.backend.store_translations :en,
                                                    :formtastic => {
                                                        :labels => {
                                                            :meta_description => @localized_label_text
                                                        }
                                                    }

                  concat(semantic_form_for(@new_post) do |builder|
                    concat(builder.input(:meta_description))
                  end)
                  output_buffer.should have_tag('form li label', /Localized title/)
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
                output_buffer.should have_tag("form li label", /#{'meta_description'.humanize}/)
              end
            end
          end

          describe 'and object is given' do
            it 'should delegate the label logic to class human attribute name and pass it down to the label tag' do
              @new_post.stub(:meta_description) # a two word method name
              @new_post.class.should_receive(:human_attribute_name).with('meta_description').and_return('meta_description'.humanize)

              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:meta_description))
              end)
              output_buffer.should have_tag("form li label", /#{'meta_description'.humanize}/)
            end
          end

          describe 'and object is given with label_str_method set to :capitalize' do
            it 'should capitalize method name, passing it down to the label tag' do
              with_config :label_str_method, :capitalize do
                @new_post.stub(:meta_description)

                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:meta_description))
                end)
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
          end

          it 'should render a label with localized label (I18n)' do
            with_config :i18n_lookups_by_default, false do
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :label => true))
                concat(builder.input(:published, :as => :boolean, :label => true))
              end)
              output_buffer.should have_tag('form li label', Regexp.new('^' + @localized_label_text))
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
              output_buffer.should have_tag('form li label', Regexp.new('^' + @default_localized_label_text))
            end
          end
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
          output_buffer.should have_tag("form li p.inline-hints", hint_text)
        end

        it 'should have a custom hint class defaulted for all forms' do
          hint_text = "this is the title of the post"
          Formtastic::FormBuilder.default_hint_class = "custom-hint-class"
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :hint => hint_text))
          end)
          output_buffer.should have_tag("form li p.custom-hint-class", hint_text)
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
                output_buffer.should have_tag('form li p.inline-hints', @localized_hint_text)
              end
            end

            it 'should render a hint paragraph containing an optional localized hint (I18n) if first is not set' do
              with_config :i18n_lookups_by_default, false do
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title, :hint => true))
                end)
                output_buffer.should have_tag('form li p.inline-hints', @default_localized_hint_text)
              end
            end
          end

          describe 'when provided value (label value) is set to FALSE' do
            it 'should not render a hint paragraph' do
              with_config :i18n_lookups_by_default, false do
                concat(semantic_form_for(@new_post) do |builder|
                  concat(builder.input(:title, :hint => false))
                end)
                output_buffer.should_not have_tag('form li p.inline-hints', @localized_hint_text)
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
              output_buffer.should_not have_tag('form li p.inline-hints', @localized_hint_text)
            end
          end
        end

        describe 'when localized hint (I18n) is not provided' do
          it 'should not render a hint paragraph' do
            with_config :i18n_lookups_by_default, false do
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title))
              end)
              output_buffer.should_not have_tag('form li p.inline-hints')
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
          output_buffer.should have_tag("form li#another_id")
        end

        it 'should append given classes to li default classes' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:class => :another_class}, :required => true))
          end)
          output_buffer.should have_tag("form li.string")
          output_buffer.should have_tag("form li.required")
          output_buffer.should have_tag("form li.another_class")
        end

        it 'should allow classes to be an array' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title, :wrapper_html => {:class => [ :my_class, :another_class ]}))
          end)
          output_buffer.should have_tag("form li.string")
          output_buffer.should have_tag("form li.my_class")
          output_buffer.should have_tag("form li.another_class")
        end

        describe 'when nil' do
          it 'should not put an id attribute on the div tag' do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :wrapper_html => {:id => nil}))
            end)
            output_buffer.should have_tag('form li:not([id])')
          end
        end
      end

      describe 'when not provided' do
        it 'should use default id and class' do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:title))
          end)
          output_buffer.should have_tag("form li#post_title_input")
          output_buffer.should have_tag("form li.string")
        end
      end

    end

    describe ':collection option' do

      it "should be required on polymorphic associations" do
        @new_post.stub(:commentable)
        @new_post.class.stub(:reflections).and_return({
                                                          :commentable => double('macro_reflection', :options => { :polymorphic => true }, :macro => :belongs_to)
                                                      })
        @new_post.stub(:column_for_attribute).with(:commentable).and_return(
            double('column', :type => :integer)
        )
        @new_post.class.stub(:reflect_on_association).with(:commentable).and_return(
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
      output_buffer.should have_tag 'li.string', :count => 2
    end
  end

  describe 'instantiating an input class' do
    context 'when a class does not exist' do
      it "should raise an error" do
        lambda {
          concat(semantic_form_for(@new_post) do |builder|
            builder.input(:title, :as => :non_existant)
          end)
        }.should raise_error(Formtastic::UnknownInputError)
      end
    end

    context 'when a customized top-level class does not exist' do

      it 'should instantiate the Formtastic input' do
        input = double('input', :to_html => 'some HTML')
        Formtastic::Inputs::StringInput.should_receive(:new).and_return(input)
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
        Formtastic::Inputs::StringInput.should_not_receive(:new)
        ::StringInput.should_receive(:new).and_return(input)

        concat(semantic_form_for(@new_post) do |builder|
          builder.input(:title, :as => :string)
        end)
      end
    end


  end
end
