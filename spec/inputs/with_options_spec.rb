# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'string input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  describe "with_options and :wrapper_html" do
    before do
      concat(semantic_form_for(@new_post) do |builder|
        builder.with_options :wrapper_html => { :class => ['extra'] } do |opt_builder|
          concat(opt_builder.input(:title, :as => :string))
          concat(opt_builder.input(:author, :as => :radio))
        end
      end)
    end

    it "should have extra class on title" do
      expect(output_buffer.to_str).to have_tag("form li#post_title_input.extra")
    end
    it "should have title as string" do
      expect(output_buffer.to_str).to have_tag("form li#post_title_input.string")
    end
    it "should not have title as radio" do
      expect(output_buffer.to_str).not_to have_tag("form li#post_title_input.radio")
    end

    it "should have extra class on author" do
      expect(output_buffer.to_str).to have_tag("form li#post_author_input.extra")
    end
    it "should not have author as string" do
      expect(output_buffer.to_str).not_to have_tag("form li#post_author_input.string")
    end
    it "should have author as radio" do
      expect(output_buffer.to_str).to have_tag("form li#post_author_input.radio")
    end
  end
end
