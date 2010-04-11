if !defined?(::Rails::VERSION) || Rails::VERSION::MAJOR == 2
  class String
    def html_safe
      self
    end
  end
end
