describe Released::Goals::GemPushed do
  subject(:goal) do
    described_class.new(config)
  end

  let(:config) do
    {
      gem_name: 'donkey',
      gem_file_path: 'donkey.gem',
      authorization: config_authorization,
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

      it { is_expected.to be_a(Released::Failure) }
      its(:reason) { is_expected.to eql('authorization failed') }
    end

    context 'correct authorization' do
      let(:config_authorization) { correct_authorization }

      context 'response does not include requested gem' do
        let(:rubygems_gems_response_body) { JSON.dump([{ name: 'giraffe' }]) }

        it { is_expected.to be_a(Released::Failure) }
        its(:reason) { is_expected.to eql('list of owned gems does not include request gem') }
      end

      context 'response includes requested gem' do
        let(:rubygems_gems_response_body) { JSON.dump([{ name: 'donkey' }]) }

        it { is_expected.to be_a(Released::Success) }
      end
    end
  end
end
