require 'spec_helper'

RSpec.describe 'json input' do

  include FormtasticSpecHelper

  class ::Post
    include ActiveModel

    attr_accessor :author
    def initialize(author)
      @author = author
    end
  end

  let(:author) { { 'name' => 'F. Scott Fitzgerald' } }
  let(:post) { Post.new(author) }

  before do
    @output_buffer = ''
    mock_everything

    concat(semantic_form_for(post) do |builder|
      concat(builder.input(:author, as: :json))
    end)
  end

  it 'should generate json value' do
    expect(output_buffer).to have_tag("[value='#{author.to_json}']")
  end
end
