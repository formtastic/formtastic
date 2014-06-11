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

  context 'with namespace configuration set to `proc { self }`' do
    before do
      Formtastic::FormBuilder.configure namespaces_setting, proc { self }
    end

    it 'includes Object, the FormBuilder and the default namespaces' do
      expect(finder.namespaces).to eq([Object, Formtastic::FormBuilder, default])
    end

    context 'within an inherited class' do
      before do
        stub_const('CustomBuilder', Class.new(Formtastic::FormBuilder))
      end

      let(:builder) { CustomBuilder.allocate }

      it 'includes Object, the inherited builder class, and the default namespaces' do
        expect(finder.namespaces).to eq([Object, CustomBuilder, default])
      end
    end
  end

  context 'with namepsace configuration set to a custom list of modules' do
    before do
      stub_const('CustomModule', Module.new)
      stub_const('AnotherModule', Module.new)

      Formtastic::FormBuilder.configure namespaces_setting, [ CustomModule, AnotherModule ]
    end

    it 'includes Object, the custom namespace, and the default' do
      expect(finder.namespaces).to eq([Object, CustomModule, AnotherModule, default])
    end
  end

end
