require 'spec_helper'

describe 'Data Attributes' do
  include FormtasticSpecHelper


  def pend_unless_country_select_available(builder, method_name)
    if method_name == 'country' && !builder.respond_to?(:country_select)
      pending 'country_select plugin'
    end
  end

  def authors_path(*args) '/authors'; end

  let(:author) do
    ::Author.new.tap do |author|
      time = Time.now

      attributes_for_input_mock = {
        :year => time.year,
        :month => time.month,
        :day => time.day,
        :hour => time.hour,
        :min => time.min,
        :sec => time.sec,
        :to_i => 0,
        :last => 'last'
      }

      author.stub!(
        :class       => ::Author,
        :to_label    => 'Justin French',
        :new_record? => false,
        :errors      => mock('errors', :[] => nil),
        :to_key      => nil,
        :persisted?  => nil,
        :attribute_for_input => mock('attribute', attributes_for_input_mock)
      )
    end
  end

  before do
    @output_buffer = ''
  end

  formtastic_inputs.each do |klass, method_name|

    describe klass.to_s do

      context 'when data attributes are present' do

        let(:field_with_data) do
          lambda { |builder|
            pend_unless_country_select_available(builder, method_name)

            concat(builder.input(:attribute_for_input, :as => method_name,
                                 :input_html => {:id => 'with_data'},
                                 :data => {:rails => '3.1'}))
          }
        end

        it 'adds a data attribute using Rails 3.1 syntactic sugar' do
          concat(semantic_form_for(author, &field_with_data))
          output_buffer.should have_tag('[data-rails="3.1"]')
        end

      end

      context 'when data attributes are not specified' do

        let(:field_without_data) do
          lambda { |builder|
            pend_unless_country_select_available(builder, method_name)

            concat(builder.input(:attribute_for_input, :as => method_name,
                                 :input_html => {:id => 'without_data'}))
          }
        end

        it 'adds a data attribute using Rails 3.1 syntactic sugar' do
          concat(semantic_form_for(author, &field_without_data))
          output_buffer.should_not have_tag('[data-rails="3.1"]')
        end

      end

    end

  end
end
