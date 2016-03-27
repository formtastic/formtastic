RSpec.shared_context 'form builder' do
  include FormtasticSpecHelper

  before do
    @output_buffer = ''
    mock_everything
  end

  after do
    ::I18n.backend.reload!
  end
end
