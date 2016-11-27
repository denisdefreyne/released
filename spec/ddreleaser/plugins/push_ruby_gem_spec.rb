describe DDReleaser::Plugins::PushRubyGem do
  subject(:plugin) do
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

  describe '#precheck' do
    subject { plugin.precheck }

    before do
      stub_request(:get, 'https://rubygems.org/api/v1/gems.json')
        .with(headers: { 'Authorization' => correct_authorization })
        .to_return(status: 200, body: rubygems_gems_response_body)

      stub_request(:get, 'https://rubygems.org/api/v1/gems.json')
        .with(headers: { 'Authorization' => incorrect_authorization })
        .to_return(status: 401, body: 'unauthorized')
    end

    context 'incorrect authorization' do
      let(:config_authorization) { incorrect_authorization }

      it { is_expected.to be_a(DDReleaser::Failure) }
      its(:reason) { is_expected.to eql('authorization failed') }
    end

    context 'correct authorization' do
      let(:config_authorization) { correct_authorization }

      context 'response does not include requested gem' do
        let(:rubygems_gems_response_body) { JSON.dump([{ name: 'giraffe' }]) }

        it { is_expected.to be_a(DDReleaser::Failure) }
        its(:reason) { is_expected.to eql('list of owned gems does not include request gem') }
      end

      context 'response includes requested gem' do
        let(:rubygems_gems_response_body) { JSON.dump([{ name: 'donkey' }]) }

        it { is_expected.to be_a(DDReleaser::Success) }
      end
    end
  end
end
