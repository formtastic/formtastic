module FormtasticInputs
  def formtastic_inputs
    @formtastic_inputs ||= Hash[*input_classes.map do |klass|
      [klass, klass.to_s.demodulize.underscore.sub(/_input$/, '')]
    end.flatten]
  end

  private

  def input_classes
    Formtastic::Inputs.constants.select do |constant|
      constant.to_s =~ /Input$/
    end
  end
end
