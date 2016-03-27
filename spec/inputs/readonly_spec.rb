# encoding: utf-8
require 'spec_helper'

RSpec.describe 'readonly option' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  describe "placeholder text" do
    [:email, :number, :password, :phone, :search, :string, :url, :text, :date_picker, :time_picker, :datetime_picker].each do |type|

      describe "for #{type} inputs" do

        describe "when readonly is found in input_html" do
          it "sets readonly attribute" do
            concat(semantic_form_for(@new_post) do |builder|
              concat(builder.input(:title, :as => type, input_html: {readonly: true}))
            end)
              expect(output_buffer).to have_tag((type == :text ? 'textarea' : 'input') + '[@readonly]')
          end
        end

        describe "when readonly not found in input_html" do
          describe "when column is not readonly attribute" do
            it "doesn't set readonly attribute" do
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :as => type))
              end)
                expect(output_buffer).not_to have_tag((type == :text ? 'textarea' : 'input') + '[@readonly]')
            end
          end
          describe "when column is readonly attribute" do
            it "sets readonly attribute" do
              input_class = "Formtastic::Inputs::#{type.to_s.camelize}Input".constantize
              expect_any_instance_of(input_class).to receive(:readonly_attribute?).at_least(1).and_return(true)
              concat(semantic_form_for(@new_post) do |builder|
                concat(builder.input(:title, :as => type))
              end)
                expect(output_buffer).to have_tag((type == :text ? 'textarea' : 'input') + '[@readonly]')
            end
          end
        end
      end
    end
  end
end
