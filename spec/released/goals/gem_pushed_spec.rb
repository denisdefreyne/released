describe Released::Goals::GemPushed do
  subject(:goal) do
    described_class.new(config)
  end

  let(:config) do
    {
      'name' => 'donkey',
      'version' => '0.1',
      'authorization' => config_authorization,
    }
  end

  let(:config_authorization) { raise 'override me' }

  let(:correct_authorization) { 'r34l_s3cr3t' }
  let(:incorrect_authorization) { 'wrong_secret' }

  let(:rubygems_gems_response_body) { JSON.dump([{ name: 'nanoc' }]) }

  describe '#assess' do
    subject { goal.assess }

    before do
      stub_request(:get, 'http://0.0.0.0:9292/api/v1/gems')
        .with(headers: { 'Authorization' => correct_authorization })
        .to_return(status: 200, body: rubygems_gems_response_body)

      stub_request(:get, 'http://0.0.0.0:9292/api/v1/gems')
        .with(headers: { 'Authorization' => incorrect_authorization })
        .to_return(status: 401, body: 'unauthorized')
    end

    context 'incorrect authorization' do
      let(:config_authorization) { incorrect_authorization }

      it 'raises' do
        expect { subject }.to raise_error(
          RuntimeError, 'Authorization failed')
      end
    end

    context 'correct authorization' do
      let(:config_authorization) { correct_authorization }

      context 'response does not include requested gem' do
        let(:rubygems_gems_response_body) { JSON.dump([{ name: 'giraffe' }]) }

        it 'raises' do
          expect { subject }.to raise_error(
            RuntimeError, 'List of owned gems does not include request gem')
        end
      end

      context 'response includes requested gem' do
        let(:rubygems_gems_response_body) { JSON.dump([{ name: 'donkey' }]) }

        it 'raises' do
          expect { subject }.not_to raise_error
        end
      end
    end
  end
end
