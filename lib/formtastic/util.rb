# encoding: utf-8

module Formtastic
  # @private
  module Util
    extend self

    def deprecated_version_of_rails?
      false # rails_version < Gem::Version.new("4.1.0")
    end

    def rails_version
      Gem::Version.new(::Rails::VERSION::STRING)
    end

  end
end
