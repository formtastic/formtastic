# frozen_string_literal: true
def with_deprecation_silenced(&block)
  ::ActiveSupport::Deprecation.silence do
    yield
  end
end

