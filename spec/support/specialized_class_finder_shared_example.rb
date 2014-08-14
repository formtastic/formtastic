# encoding: utf-8
#
RSpec.shared_examples 'Specialized Class Finder' do
  let(:builder) { Formtastic::FormBuilder.allocate }
  subject(:finder) { described_class.new(builder) }

  context 'by default' do
    it 'includes Object and the default namespaces' do
      expect(finder.namespaces).to eq([Object, default])
    end
  end

  context 'with namespace configuration set to a custom list of modules' do
    before do
      stub_const('CustomModule', Module.new)
      stub_const('AnotherModule', Module.new)

      allow(Formtastic::FormBuilder).to receive(namespaces_setting)
                                          .and_return([ CustomModule, AnotherModule ])
    end

    it 'includes just the custom namespaces' do
      expect(finder.namespaces).to eq([CustomModule, AnotherModule])
    end
  end

end
