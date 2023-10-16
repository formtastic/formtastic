# encoding: utf-8
# frozen_string_literal: true
require 'spec_helper'

RSpec.describe 'string input' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  after do
    ::I18n.backend.reload!
  end

  describe "placeholder text" do

    [:email, :number, :password, :phone, :search, :string, :url, :text, :date_picker, :time_picker, :datetime_picker].each do |type|

      describe "for #{type} inputs" do

        describe "when found in i18n" do
          it "should have a placeholder containing i18n text" do
            with_config :i18n_lookups_by_default, true do
              ::I18n.backend.store_translations :en, :formtastic => { :placeholders => { :title => 'War and Peace' }}
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :as => type))
              end)
              expect(output_buffer.to_str).to have_tag((type == :text ? 'textarea' : 'input') + '[@placeholder="War and Peace"]')
            end
          end
        end

        describe "when not found in i18n" do
          it "should not have placeholder" do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :as => type))
            end)
            expect(output_buffer.to_str).not_to have_tag((type == :text ? 'textarea' : 'input') + '[@placeholder]')
          end
        end

        describe "when found in i18n and :input_html" do
          it "should favor :input_html" do
            with_config :i18n_lookups_by_default, true do
              ::I18n.backend.store_translations :en, :formtastic => { :placeholders => { :title => 'War and Peace' }}
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :as => type, :input_html => { :placeholder => "Foo" }))
              end)
              expect(output_buffer.to_str).to have_tag((type == :text ? 'textarea' : 'input') + '[@placeholder="Foo"]')
            end
          end
        end

        describe "when found in :input_html" do
          it "should use the :input_html placeholder" do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :as => type, :input_html => { :placeholder => "Untitled" }))
            end)
            expect(output_buffer.to_str).to have_tag((type == :text ? 'textarea' : 'input') + '[@placeholder="Untitled"]')
          end
        end

      end

    end

  end

end
