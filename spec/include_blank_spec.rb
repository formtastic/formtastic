# encoding: utf-8
require 'spec_helper'

describe "*select: options[:include_blank]" do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything

    @new_post.stub!(:author_id).and_return(nil)
    @new_post.stub!(:publish_at).and_return(nil)

    @select_input_types = {
        :select => :author,
        :datetime => :publish_at,
        :date => :publish_at,
        :time => :publish_at
      }
  end

  describe 'when :include_blank is not set' do
    it 'blank value should be included if the default value specified in config is true' do
      Formtastic::FormBuilder.include_blank_for_select_by_default = true
      @select_input_types.each do |as, attribute|
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(attribute, :as => as))
        end)
        output_buffer.should have_tag("form li select option[@value='']", "")
      end
    end

    it 'blank value should not be included if the default value specified in config is false' do
      Formtastic::FormBuilder.include_blank_for_select_by_default = false
      @select_input_types.each do |as, attribute|
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(attribute, :as => as))
        end)
        output_buffer.should_not have_tag("form li select option[@value='']", "")
      end
    end

    after do
      Formtastic::FormBuilder.include_blank_for_select_by_default = true
    end
  end

  describe 'when :include_blank is set to false' do
    it 'should not have a blank option' do
      @select_input_types.each do |as, attribute|
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(attribute, :as => as, :include_blank => false))
        end)
        output_buffer.should_not have_tag("form li select option[@value='']", "")
      end
    end
  end

  describe 'when :include_blank => true is set' do
    it 'should have a blank select option' do
      @select_input_types.each do |as, attribute|
        concat(semantic_form_for(@new_post) do |builder|
          concat(builder.input(attribute, :as => as, :include_blank => true))
        end)
        output_buffer.should have_tag("form li select option[@value='']", "")
      end
    end
  end
end
