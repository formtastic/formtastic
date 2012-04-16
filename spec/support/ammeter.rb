require 'ammeter'
# Rails 4 changes the implementation of delegate to no longer use send.  
#Because of this it can no longer be used to delegate to a protected of another object as Ammeter attempts to do for prepare_destination
#Monkey patch Ammeter to call send itself for perpare_destination when in Rails 4.
#Needed until Ammeter fixes itself
module Ammeter
  module RSpec
    module Rails
      # Delegates to Rails::Generators::TestCase to work with RSpec.
      module GeneratorExampleGroup
        module ClassMethods
          def prepare_destination
            self.test_unit_test_case_delegate.send :prepare_destination
          end
        end
      end
    end
  end
end if ::Rails::VERSION::MAJOR == 4