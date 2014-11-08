require 'fast_spec_helper'
require 'inputs/base/collections'

class MyInput
  include Formtastic::Inputs::Base::Collections
end

describe MyInput do
  let(:builder) { double }
  let(:template) { double }
  let(:model) { double }
  let(:model_name) { double }
  let(:method) { double }
  let(:options) { Hash.new }
  
  let(:instance) { MyInput.new(builder, template, model, model_name, method, options) }

  # class Whatever < ActiveRecord::Base
  #   enum :status => [:active, :archived]
  # end
  #
  # Whatever.statuses
  #
  # Whatever.new.status
  #
  # f.input :status
  describe "#collection_from_enum" do
    
    let(:method) { :status }

    context "when an enum is defined for the method" do
      it 'returns an Array based on the enum options hash' do
        statuses = ActiveSupport::HashWithIndifferentAccess.new("active"=>0, "inactive"=>1)
        model.stub(:statuses) { statuses }
        model.stub(:defined_enums) { {"status" => statuses } }
        instance.collection_from_enum.should eq [ ["active", 0], ["inactive", 1] ]
      end
    end

    context "when an enum is not defined" do
      it 'returns nil' do
        instance.collection_from_enum.should eq nil
      end
    end
  end

end
