describe Released::Goals::GemBuilt do
  subject(:goal) do
    described_class.new(config)
  end

  let(:config) do
    {
      'name' => 'donkey',
      'version' => '0.1',
    }
  end

  let(:donkey_gemspec) do
    <<~STRING
      Gem::Specification.new do |s|
        s.name    = 'donkey'
        s.version = '0.1'

        s.summary = 'the cutest animal'
        s.author  = 'Denis Defreyne'
        s.email   = 'denis.defreyne@stoneship.org'
        s.license = 'MIT'

        s.files   = []
      end
    STRING
  end

  describe '#achieved?' do
    subject { goal.achieved? }

    context 'file exists' do
      before { File.write('donkey-0.1.gem', 'hello!') }
      it { is_expected.to eql(true) }
    end

    context 'file does not exist' do
      it { is_expected.to eql(false) }
    end
  end

  describe '#try_achieve' do
    subject { goal.try_achieve }

    context 'no gemspec' do
      it 'raises' do
        expect { subject }.to raise_error(/Gemspec file not found/)
      end
    end

    context 'valid gemspec' do
      before { File.write('donkey.gemspec', donkey_gemspec) }

      it 'builds the gem' do
        expect { subject }.to change { File.file?('donkey-0.1.gem') }.from(false).to(true)
      end

      context 'other gems already exist' do
        before { File.write('foo-1.0.gem', 'stuff') }

        it 'builds the gem' do
          expect { subject }.to change { File.file?('donkey-0.1.gem') }.from(false).to(true)
        end

        it 'does not remove other gems' do
          expect { subject }.not_to change { File.file?('foo-1.0.gem') }
        end
      end
    end
  end

  describe '#failure_reason' do
    subject { goal.failure_reason }
    it { is_expected.to eql('file donkey-0.1.gem does not exist') }
  end
end
