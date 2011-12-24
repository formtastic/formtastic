require 'active_support/core_ext/string/inflections'

module FormtasticInputs
  class InputFinder
    def to_hash
      Hash[*names.flatten]
    end

    private

    def paths
      Dir[File.expand_path('../../../lib/formtastic/inputs/*_input.rb', __FILE__)]
    end

    def names
      paths.map do |path|
        base = File.basename(path, '.rb')
        [base.camelize.to_sym, base.sub(/_input$/, '')]
      end.compact
    end
  end

  def formtastic_inputs
    InputFinder.new.to_hash
  end
end
