# frozen_string_literal: true
module Formtastic
  module Helpers
    # @private
    module FileColumnDetection

      # Return true if we are explicitly told to be a file via the :as option, or if we appear to be
      # a file based on `file_methods`. Be sure to exclude `StringInquirer` objects since they will
      # respond to inquisitive methods such as :file?, but they are not files.
      def is_file?(method, options = {})
        @files ||= {}
        @files[method] ||= (options[:as].present? && options[:as] == :file) || begin
          file = @object.send(method) if @object&.respond_to?(method)
          file && file_methods.any? { |m|
            file.respond_to?(m)
          } && !file.is_a?(ActiveSupport::StringInquirer)
        end
      end

    end
  end
end
