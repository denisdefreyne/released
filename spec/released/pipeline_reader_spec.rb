describe Released::PipelineReader do
  subject(:pipeline_reader) { described_class.new(filename) }

  let(:filename) { 'pipeline.yaml' }

  before do
    ENV['FAVORITE_GEM_AUTHOR'] = 'denis'
  end

  describe '#transform' do
    subject { pipeline_reader.send(:transform, obj, vars) }

    let(:vars) { {} }

    context 'with array' do
      let(:obj) { %w(hello env!FAVORITE_GEM_AUTHOR) }
      it { is_expected.to eql(%w(hello denis)) }
    end

    context 'with hash' do
      let(:obj) { { people: ['env!FAVORITE_GEM_AUTHOR'] } }
      it { is_expected.to eql(people: ['denis']) }
    end

    context 'with string' do
      context 'normal string' do
        let(:obj) { 'hello' }
        it { is_expected.to eql(obj) }
      end

      context 'env! string' do
        let(:obj) { 'env!FAVORITE_GEM_AUTHOR' }
        it { is_expected.to eql('denis') }
      end

      context 'sh! string' do
        let(:obj) { 'sh!echo -n hello' }
        it { is_expected.to eql('hello') }
      end

      context 'var! string' do
        let(:obj) { 'var!version' }

        context 'var does not exist' do
          # TODO
        end

        context 'var exists' do
          let(:vars) { { 'version' => '1.2.4' } }
          it { is_expected.to eql('1.2.4') }
        end
      end

      context 'encrypted string' do
        # TODO
      end
    end

    context 'with anything else' do
      let(:obj) { :donkey }
      it { is_expected.to eql(obj) }
    end
  end
end
