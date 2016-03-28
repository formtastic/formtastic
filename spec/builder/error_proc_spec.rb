# encoding: utf-8
require 'spec_helper'

RSpec.describe 'Rails field_error_proc' do

  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  it "should not be overridden globally for all form builders" do
    current_field_error_proc = ::ActionView::Base.field_error_proc

    semantic_form_for(@new_post) do |builder|
      expect(::ActionView::Base.field_error_proc).not_to eq(current_field_error_proc)
    end

    expect(::ActionView::Base.field_error_proc).to eq(current_field_error_proc)

    form_for(@new_post) do |builder|
      expect(::ActionView::Base.field_error_proc).to eq(current_field_error_proc)
    end
  end

end
