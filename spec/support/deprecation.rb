def with_deprecation_silenced(&block)
  ::ActiveSupport::Deprecation.silenced = true
  yield
  ::ActiveSupport::Deprecation.silenced = false
end

