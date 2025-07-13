# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'Formtastic::FormBuilder#label' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  it 'should add "required string" only once with caching enabled' do
    with_config :i18n_cache_lookups, true do
      ::I18n.backend.store_translations :en, { :formtastic => { :labels => { :post => { :title => "I18n title" } } } }
      required_string = "[req_string]"
      default_required_str = Formtastic::FormBuilder.required_string
      Formtastic::FormBuilder.required_string = required_string

      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :required => true, :label => true)
      end)
      @output_buffer = ActionView::OutputBuffer.new ''
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :required => true, :label => true)
      end)

      ::I18n.backend.store_translations :en, { :formtastic => { :labels => { :post => { :title => nil } } } }
      Formtastic::FormBuilder.required_string = default_required_str

      expect(output_buffer.to_s.scan(required_string).count).to eq(1)
    end
  end

  it 'should humanize the given attribute' do
    concat(semantic_form_for(@new_post) do |builder|
      builder.input(:title)
    end)
    expect(output_buffer.to_str).to have_tag('label', :text => /Title/)
  end

  it 'should apply a "for" attribute to the label' do
    concat(semantic_form_for(@new_post) do |builder|
      builder.input(:title)
    end)
    expect(output_buffer.to_str).to have_tag('label[for=post_title]')
  end

  it 'should apply a "label" class to the label' do
    concat(semantic_form_for(@new_post) do |builder|
      builder.input(:title)
    end)
    expect(output_buffer.to_str).to have_tag('label.label')
  end

  it 'should use i18n instead of the method name when method given as a String' do
    with_config :i18n_cache_lookups, true do
      ::I18n.backend.store_translations :en, { :formtastic => { :labels => { :post => { :title => "I18n title" } } } }
      concat(semantic_form_for(@new_post) do |builder|
        builder.input("title")
      end)
      ::I18n.backend.store_translations :en, { :formtastic => { :labels => { :post => { :title => nil } } } }
      expect(output_buffer.to_str).to have_tag('label', :text => /I18n title/)
    end
  end

  it 'should humanize the given attribute for date fields' do
    concat(semantic_form_for(@new_post) do |builder|
      builder.input(:publish_at)
    end)
    expect(output_buffer.to_str).to have_tag('label', :text => /Publish at/)
  end

  describe 'when required is given' do
    it 'should append a required note' do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :required => true)
      end)
      expect(output_buffer.to_str).to have_tag('label abbr', '*')
    end
  end

  describe "when label_html is given" do
    it "should allow label_html to override the class" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :label_html => { :class => 'my_class' } )
      end)
      expect(output_buffer.to_str).to have_tag('label.my_class', /Title/)
    end

    it "should allow label_html to add custom attributes" do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :label_html => { :data => { :tooltip => 'Great Tooltip' } } )
      end)
      aggregate_failures do
        expect(output_buffer.to_str).to have_tag('label[data-tooltip="Great Tooltip"]')
      end
    end
  end 

  describe 'when a collection is given' do
    it 'should use a supplied label_method for simple collections' do
      with_deprecation_silenced do
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => [:a, :b, :c], :member_value => :to_s, :member_label => proc {|f| ('Label_%s' % [f])}))
        end)
      end
      expect(output_buffer.to_str).to have_tag('form li fieldset ol li label', :text => /Label_[abc]/, :count => 3)
    end

    it 'should use a supplied value_method for simple collections' do
      with_deprecation_silenced do
        concat(semantic_form_for(:project, :url => 'http://test.host') do |builder|
          concat(builder.input(:author_id, :as => :check_boxes, :collection => [:a, :b, :c], :member_value => proc {|f| ('Value_%s' % [f.to_s])}))
        end)
      end
      expect(output_buffer.to_str).to have_tag('form li fieldset ol li label input[value="Value_a"]')
      expect(output_buffer.to_str).to have_tag('form li fieldset ol li label input[value="Value_b"]')
      expect(output_buffer.to_str).to have_tag('form li fieldset ol li label input[value="Value_c"]')
    end
  end

  describe 'when label is given' do
    it 'should allow the text to be given as label option' do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :label => 'My label')
      end)
      expect(output_buffer.to_str).to have_tag('label', :text => /My label/)
    end

    it 'should allow the text to be given as label option for date fields' do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:publish_at, :label => 'My other label')
      end)
      expect(output_buffer.to_str).to have_tag('label', :text => /My other label/)
    end

    it 'should return nil if label is false' do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :label => false)
      end)
      expect(output_buffer.to_str).not_to have_tag('label')
      expect(output_buffer.to_str).not_to include("&gt;")
    end

    it 'should return nil if label is false for timeish fragments' do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :as => :time_select, :label => false)
      end)
      expect(output_buffer.to_str).not_to have_tag('li.time > label')
      expect(output_buffer.to_str).not_to include("&gt;")
    end

    it 'should html escape the label string by default' do
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :label => '<b>My label</b>')
      end)
      expect(output_buffer.to_str).to include('&lt;b&gt;')
      expect(output_buffer.to_str).not_to include('<b>')
    end

    it 'should not html escape the label if configured that way' do
      Formtastic::FormBuilder.escape_html_entities_in_hints_and_labels = false
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :label => '<b>My label</b>')
      end)
      expect(output_buffer.to_str).to have_tag("label b", :text => "My label")
    end

    it 'should not html escape the label string for html_safe strings' do
      Formtastic::FormBuilder.escape_html_entities_in_hints_and_labels = true
      concat(semantic_form_for(@new_post) do |builder|
        builder.input(:title, :label => '<b>My label</b>'.html_safe)
      end)
      expect(output_buffer.to_str).to have_tag('label b')
    end

  end

end

