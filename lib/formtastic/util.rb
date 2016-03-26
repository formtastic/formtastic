# encoding: utf-8

module Formtastic
  # @private
  module Util
    extend self

    def deprecated_version_of_rails?
      match?(rails_version, "< #{minimum_version_of_rails}")
    end

    def minimum_version_of_rails
      "4.1.0"
    end

    def rails_version
      ::Rails::VERSION::STRING
    end

    def match?(version, dependency)
      Gem::Dependency.new("formtastic", dependency).match?("formtastic", version)
    end

  end
end
