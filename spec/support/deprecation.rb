def with_deprecation_silenced(&block)
  previous_value = ::ActiveSupport::Deprecation.silenced
  ::ActiveSupport::Deprecation.silenced = true
  yield
  ::ActiveSupport::Deprecation.silenced = previous_value
end

