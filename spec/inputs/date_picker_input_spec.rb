# encoding: utf-8
require 'spec_helper'

describe 'date_picker input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end
  
  context "with an object" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :date_picker))
      end)
    end
    
    it_should_have_input_wrapper_with_class(:date_picker)
    it_should_have_input_wrapper_with_class(:input)
    it_should_have_input_wrapper_with_class(:stringish)
    it_should_have_input_wrapper_with_id("post_publish_at_input")
    it_should_have_label_with_text(/Publish at/)
    it_should_have_label_for("post_publish_at")
    it_should_have_input_with_id("post_publish_at")
    it_should_have_input_with_type(:date)
    it_should_have_input_with_name("post[publish_at]")
    it_should_apply_custom_input_attributes_when_input_html_provided(:date_picker)
    it_should_apply_custom_for_to_label_when_input_html_id_provided(:date_picker)
    # TODO why does this blow-up it_should_apply_error_logic_for_input_type(:date_picker)
    
  end
  
  describe "size attribute" do
    
    it "defaults to 10 chars (YYYY-YY-YY)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker))
        end
      )
      output_buffer.should have_tag "input[size='10']"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :input_html => { :size => "11" }))
        end
      )
      output_buffer.should have_tag "input[size='11']"
    end
    
    it "can be set from options (ignoring input_html)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :size => '12', :input_html => { :size => "11" }))
        end
      )
      output_buffer.should have_tag "input[size='12']"
    end

  end

  describe "maxlength attribute" do

    it "defaults to 10 chars (YYYY-YY-YY)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker))
        end
      )
      output_buffer.should have_tag "input[maxlength='10']"
    end

    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :input_html => { :maxlength => "11" }))
        end
      )
      output_buffer.should have_tag "input[maxlength='11']"
    end
    
    it "can be set from options (ignoring input_html)" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :maxlength => 12, :input_html => { :maxlength => "11" }))
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
            concat(f.input(:publish_at, :as => :date_picker ))
          end
        )
        output_buffer.should_not have_tag "li input[value]"
      end
      
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker, :input_html => { :value => "1111-11-11" }))
          end
        )
        output_buffer.should have_tag "input[value='1111-11-11']"
      end
      
    end
  
    context "when method returns a Date" do
      
      before do
        @date = Date.new(2000, 11, 11)
        @new_post.stub(:publish_at).and_return(@date)
      end
      
      it "renders the date as YYYY-MM-DD" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker ))
          end
        )
        output_buffer.should have_tag "input[value='#{@date.to_s}']"
      end

      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker, :input_html => { :value => "1111-11-11" }))
          end
        )
        output_buffer.should have_tag "input[value='1111-11-11']"
      end
      
    end
  
    context "when method returns a Time" do
    
      before do
        @time = Time.utc(2000,11,11,11,11,11)
        @new_post.stub(:publish_at).and_return(@time)
      end
      
      it "renders the time as a YYYY-MM-DD" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker ))
          end
        )
        output_buffer.should have_tag "input[value='2000-11-11']"
      end
    
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker, :input_html => { :value => "1111-11-11" }))
          end
        )
        output_buffer.should have_tag "input[value='1111-11-11']"
      end
      
    end
  
    context "when method returns an empty String" do
      
      before do
        @new_post.stub(:publish_at).and_return("")
      end
      
      it "will be empty" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker ))
          end
        )
        output_buffer.should have_tag "input[value='']"
      end
      
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker, :input_html => { :value => "1111-11-11" }))
          end
        )
        output_buffer.should have_tag "input[value='1111-11-11']"
      end
      
    end
  
    context "when method returns a String" do
      
      before do
        @new_post.stub(:publish_at).and_return("yeah")
      end
      
      it "will be the string" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker ))
          end
        )
        output_buffer.should have_tag "input[value='yeah']"
      end
    
      it "can be set from :input_html options" do
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker, :input_html => { :value => "1111-11-11" }))
          end
        )
        output_buffer.should have_tag "input[value='1111-11-11']"
      end
      
    end

  end
  
  describe "min attribute" do
    
    it "will be omitted by default" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker))
        end
      )
      output_buffer.should_not have_tag "input[min]"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :input_html => { :min => "1970-01-01" }))
        end
      )
      output_buffer.should have_tag "input[min='1970-01-01']"
    end
    
  end
  
  describe "max attribute" do

    it "will be omitted by default" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker))
        end
      )
      output_buffer.should_not have_tag "input[max]"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :input_html => { :max => "1970-01-01" }))
        end
      )
      output_buffer.should have_tag "input[max='1970-01-01']"
    end
    
  end
  
  describe "step attribute" do
    
    it "defaults to 1" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker))
        end
      )
      output_buffer.should have_tag "input[step='1']"
    end

    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :input_html => { :step => "5" }))
        end
      )
      output_buffer.should have_tag "input[step='5']"
    end
    
    describe "macros" do
      
      before do 
        concat(
          semantic_form_for(@new_post) do |f|
            concat(f.input(:publish_at, :as => :date_picker, :input_html => { :step => step }))
          end
        )
      end
      
      context ":day" do
        let(:step) { :day }
        it "uses 1" do
          output_buffer.should have_tag "input[step='1']"
        end
      end
      
      context ":seven_days" do
        let(:step) { :seven_days }
        it "uses 7" do
          output_buffer.should have_tag "input[step='7']"
        end
      end
      
      context ":week" do
        let(:step) { :week }
        it "uses 7" do
          output_buffer.should have_tag "input[step='7']"
        end
      end
      
      context ":fortnight" do
        let(:step) { :fortnight }
        it "uses 14" do
          output_buffer.should have_tag "input[step='14']"
        end
      end
      
      context ":two_weeks" do
        let(:step) { :two_weeks }
        it "uses 14" do
          output_buffer.should have_tag "input[step='14']"
        end
      end
      
      context ":four_weeks" do
        let(:step) { :four_weeks }
        it "uses 28" do
          output_buffer.should have_tag "input[step='28']"
        end
      end
      
      context ":thirty_days" do
        let(:step) { :thirty_days }
        it "uses 30" do
          output_buffer.should have_tag "input[step='30']"
        end
      end
      
    end
    
  end
  
  describe "placeholder attribute" do
    
    it "will be omitted" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker))
        end
      )
      output_buffer.should_not have_tag "input[placeholder]"
    end
    
    it "can be set from :input_html options" do
      concat(
        semantic_form_for(@new_post) do |f|
          concat(f.input(:publish_at, :as => :date_picker, :input_html => { :placeholder => "1970-01-01" }))
        end
      )
      output_buffer.should have_tag "input[placeholder='1970-01-01']"
    end
    
    context "with i18n set" do
      before do
        ::I18n.backend.store_translations :en, :formtastic => { :placeholders => { :publish_at => 'YYYY-MM-DD' }}
      end
      
      it "can be set with i18n" do
        with_config :i18n_lookups_by_default, true do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:publish_at, :as => :date_picker))
          end)
          output_buffer.should have_tag('input[@placeholder="YYYY-MM-DD"]')
        end
      end
      
      it "can be set with input_html, trumping i18n" do
        with_config :i18n_lookups_by_default, true do
          concat(semantic_form_for(@new_post) do |builder|
            concat(builder.input(:publish_at, :as => :date_picker, :input_html => { :placeholder => "Something" }))
          end)
          output_buffer.should have_tag('input[@placeholder="Something"]')
        end
      end
    end
    
  end
  
  describe "when namespace is provided" do
    before do
      concat(semantic_form_for(@new_post, :namespace => "context2") do |builder|
        concat(builder.input(:publish_at, :as => :date_picker))
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
          concat(author.input(:created_at, :as => :date_picker))
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
          concat(builder.input(:publish_at, :as => :date_picker, :required => true))
        end)
        output_buffer.should have_tag("input[@required]")
      end
    end
  end
  
end