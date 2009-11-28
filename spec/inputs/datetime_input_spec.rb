# coding: utf-8
require File.dirname(__FILE__) + '/../spec_helper'

describe 'datetime input' do
  
  include FormtasticSpecHelper
  
  before do
    @output_buffer = ''
    mock_everything
    
    @new_post.should_receive(:publish_at=).any_number_of_times
    @new_post.should_receive(:created_at=).any_number_of_times
    @bob.should_receive(:created_at=).any_number_of_times
    @new_post.should_receive(:title=).any_number_of_times # Macro stuff forces this.
    
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

  it_should_select_existing_datetime_else_current(:year, :month, :day, :hour, :minute, :second)
  it_should_select_explicit_default_value_if_set(:year, :month, :day, :hour, :minute, :second)

  describe 'when :discard_input => true is set' do
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
      ::I18n.backend.store_translations 'en', :date => { :order => [:month, :year, :day] }
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
      ::I18n.backend.store_translations 'en', :datetime => {:prompts => {
        :year => 'The Year', :month => 'The Month', :day => 'The Day',
        :hour => 'The Hour', :minute => 'The Minute'
      }}
      semantic_form_for(@new_post) do |builder|
        concat(builder.input(:publish_at, :as => :datetime))
      end
    end

    after do
      ::I18n.backend.store_translations 'en', :formtastic => {
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

    it 'should have fieldset with legend - classified as a label' do
      output_buffer.should have_tag('form li.datetime fieldset legend.label', /Publish at/)
    end

    it 'should have labels for each input' do
      output_buffer.should have_tag('form li.datetime fieldset ol li label', :count => 5)
    end

    it 'should have selects for each inputs' do
      output_buffer.should have_tag('form li.datetime fieldset ol li select', :count => 5)
    end
  end

end

