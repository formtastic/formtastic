# encoding: utf-8
require 'spec_helper'

describe 'time_picker input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end
  
  context "with an object" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :time_picker))
      end)
    end
    
    it_should_have_input_wrapper_with_class(:time_picker)
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_class(:stringish)
    it_should_have_input_wrapper_with_id("post_publish_at_input")
    it_should_have_label_with_text(/Publish at/)
    it_should_have_label_for("post_publish_at")
    it_should_have_input_with_id("post_publish_at")
    it_should_have_input_with_type(:time)
    it_should_have_input_with_name("post[publish_at]")
    it_should_apply_custom_input_attributes_when_input_html_provided(:date_picker)
    it_should_apply_custom_for_to_label_when_input_html_id_provided(:date_picker)
    # TODO why does this blow-up it_should_apply_error_logic_for_input_type(:date_picker)
    
  end
  
  describe "size attribute" do
    
    it "defaults to 5 chars (HH:MM)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker))
        end
      )
      output_buffer.should have_tag "input[size='5']"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :input_html => { :size => "11" }))
        end
      )
      output_buffer.should have_tag "input[size='11']"
    end
    
    it "can be set from options (ignoring input_html)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :size => '12', :input_html => { :size => "11" }))
        end
      )
      output_buffer.should have_tag "input[size='12']"
    end

  end

  describe "maxlength attribute" do

    it "defaults to 5 chars (HH:MM:SS)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker))
        end
      )
      output_buffer.should have_tag "input[maxlength='5']"
    end

    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :input_html => { :maxlength => "11" }))
        end
      )
      output_buffer.should have_tag "input[maxlength='11']"
    end
    
    it "can be set from options (ignoring input_html)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :maxlength => 12, :input_html => { :maxlength => "11" }))
        end
      )
      output_buffer.should have_tag "input[maxlength='12']"
    end
    
  end
  
  describe "value attribute" do
  
    context "when method returns nil" do
      
      it "has no value" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker ))
          end
        )
        output_buffer.should_not have_tag "li input[value]"
      end
      
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker, :input_html => { :value => "12:00" }))
          end
        )
        output_buffer.should have_tag "input[value='12:00']"
      end
      
    end
  
    context "when method returns a Date" do
      
      before do
        @date = Date.new(2000, 11, 11)
        @new_post.stub(:publish_at).and_return(@date)
      end
      
      it "renders 00:00" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker ))
          end
        )
        output_buffer.should have_tag "input[value='00:00']"
      end

      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker, :input_html => { :value => "23:59" }))
          end
        )
        output_buffer.should have_tag "input[value='23:59']"
      end
      
    end
  
    context "when method returns a Time" do
    
      before do
        @time = Time.utc(2000,11,11,11,11,11)
        @new_post.stub(:publish_at).and_return(@time)
      end
      
      it "renders the time as a HH:MM" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker ))
          end
        )
        output_buffer.should have_tag "input[value='11:11']"
      end
    
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker, :input_html => { :value => "12:12" }))
          end
        )
        output_buffer.should have_tag "input[value='12:12']"
      end
      
    end
  
    context "when method returns an empty String" do
      
      before do
        @new_post.stub(:publish_at).and_return("")
      end
      
      it "will be empty" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker ))
          end
        )
        output_buffer.should have_tag "input[value='']"
      end
      
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker, :input_html => { :value => "12:12:12" }))
          end
        )
        output_buffer.should have_tag "input[value='12:12:12']"
      end
      
    end
  
    context "when method returns a String" do
      
      before do
        @new_post.stub(:publish_at).and_return("yeah")
      end
      
      it "will be the string" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker ))
          end
        )
        output_buffer.should have_tag "input[value='yeah']"
      end
    
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :time_picker, :input_html => { :value => "12:12:12" }))
          end
        )
        output_buffer.should have_tag "input[value='12:12:12']"
      end
      
    end

  end
  
  describe "min attribute" do
    
    it "will be omitted by default" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker))
        end
      )
      output_buffer.should_not have_tag "input[min]"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :input_html => { :min => "13:00" }))
        end
      )
      output_buffer.should have_tag "input[min='13:00']"
    end
    
  end
  
  describe "max attribute" do

    it "will be omitted by default" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker))
        end
      )
      output_buffer.should_not have_tag "input[max]"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :input_html => { :max => "13:00" }))
        end
      )
      output_buffer.should have_tag "input[max='13:00']"
    end
    
  end
  
  describe "step attribute" do
    
    it "defaults to 60 (seconds)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker))
        end
      )
      output_buffer.should have_tag "input[step='60']"
    end

    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :input_html => { :step => "3600" }))
        end
      )
      output_buffer.should have_tag "input[step='3600']"
    end
    
    describe "macros" do
      before do 
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker, :input_html => { :step => step }))
          end
        )
      end
      
      context ":second" do
        let(:step) { :second }
        it "uses 1" do
          output_buffer.should have_tag "input[step='1']"
        end
      end
      
      context ":minute" do
        let(:step) { :minute }
        it "uses 60" do
          output_buffer.should have_tag "input[step='60']"
        end
      end
      
      context ":fifteen_minutes" do
        let(:step) { :fifteen_minutes }
        it "uses 900" do
          output_buffer.should have_tag "input[step='900']"
        end
      end
      
      context ":quarter_hour" do
        let(:step) { :quarter_hour }
        it "uses 900" do
          output_buffer.should have_tag "input[step='900']"
        end
      end
      
      context ":thirty_minutes" do
        let(:step) { :thirty_minutes }
        it "uses 1800" do
          output_buffer.should have_tag "input[step='1800']"
        end
      end
      
      context ":half_hour" do
        let(:step) { :half_hour }
        it "uses 1800" do
          output_buffer.should have_tag "input[step='1800']"
        end
      end
      
      context ":hour" do
        let(:step) { :hour }
        it "uses 3600" do
          output_buffer.should have_tag "input[step='3600']"
        end
      end
      
      context ":sixty_minutes" do
        let(:step) { :sixty_minutes }
        it "uses 3600" do
          output_buffer.should have_tag "input[step='3600']"
        end
      end
      
    end
        
  end
  
  describe "placeholder attribute" do
    
    it "will be omitted" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker))
        end
      )
      output_buffer.should_not have_tag "input[placeholder]"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :time_picker, :input_html => { :placeholder => "HH:MM" }))
        end
      )
      output_buffer.should have_tag "input[placeholder='HH:MM']"
    end
    
    context "with i18n set" do
      before do
        ::I18n.backend.store_translations :en, :formtastic => { :placeholders => { :publish_at => 'HH:MM' }}
      end
      
      it "can be set with i18n" do
        with_config :i18n_lookups_by_default, true do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:publish_at, :as => :time_picker))
          end)
          output_buffer.should have_tag('input[@placeholder="HH:MM"]')
        end
      end
      
      it "can be set with input_html, trumping i18n" do
        with_config :i18n_lookups_by_default, true do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:publish_at, :as => :time_picker, :input_html => { :placeholder => "Something" }))
          end)
          output_buffer.should have_tag('input[@placeholder="Something"]')
        end
      end
    end
    
  end
  
  describe "when namespace is provided" do
    before do
      concat(semantic_form_for(@new_post, :namespace => "context2") do |builder|
        concat(builder.input(:publish_at, :as => :time_picker))
      end)
    end

    it_should_have_input_wrapper_with_id("context2_post_publish_at_input")
    it_should_have_label_and_input_with_id("context2_post_publish_at")
  end
  
  describe "when index is provided" do
    before do
      @output_buffer = ''
      mock_everything

      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.fields_for(:author, :index => 3) do |author|
          concat(author.input(:created_at, :as => :time_picker))
        end)
      end)
    end
    
    it 'should index the id of the wrapper' do
      output_buffer.should have_tag("li#post_author_attributes_3_created_at_input")
    end
    
    it 'should index the id of the select tag' do
      output_buffer.should have_tag("input#post_author_attributes_3_created_at")
    end
    
    it 'should index the name of the select tag' do
      output_buffer.should have_tag("input[@name='post[author_attributes][3][created_at]']")
    end
  end
  
  describe "when required" do
    it "should add the required attribute to the input's html options" do
      with_config :use_required_attribute, true do 
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(:publish_at, :as => :time_picker, :required => true))
        end)
        output_buffer.should have_tag("input[@required]")
      end
    end
  end
  
end