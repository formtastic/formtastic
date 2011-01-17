module Formtastic
  module Reflection
    # If an association method is passed in (f.input :author) try to find the
    # reflection object.
    #
    def reflection_for(method) #:nodoc:
      @object.class.reflect_on_association(method) if @object.class.respond_to?(:reflect_on_association)
    end
  end
end