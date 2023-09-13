# frozen_string_literal: true
RSpec.shared_context 'form builder' do
  include FormtasticSpecHelper

  before do
    @output_buffer = ActionView::OutputBuffer.new ''
    mock_everything
  end

  after do
    ::I18n.backend.reload!
  end
end
