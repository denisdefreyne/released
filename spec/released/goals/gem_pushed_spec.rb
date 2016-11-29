describe Released::Goals::GemPushed, stdio: true do
  subject(:goal) do
    described_class.new(config)
  end

  let(:config) do
    {
      'name' => 'donkey',
      'version' => '0.1',
      'authorization' => config_authorization,
      'rubygems_base_url' => "http://0.0.0.0:#{port}",
    }
  end

  let(:config_authorization) { raise 'override me' }

  let(:correct_authorization) { 'r34l_s3cr3t' }
  let(:incorrect_authorization) { 'wrong_secret' }

  let(:rubygems_gems_response_body) { JSON.dump([{ name: 'nanoc' }]) }

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

  let(:port) { 35_661 }

  before do
    File.write('donkey.gemspec', donkey_gemspec)
    system('gem', 'build', '--silent', 'donkey.gemspec')
  end

  def run_fake_gem_server_while
    pid = fork do
      Dir.mktmpdir('released-specs-geminabox') do |dir|
        require 'geminabox'
        Geminabox.data = dir
        Rack::Handler::WEBrick.run(Geminabox::Server, Port: port)
      end
    end

    # Wait for server to start up
    20.times do |i|
      begin
        Net::HTTP.get('0.0.0.0', '/', port)
      rescue Errno::ECONNREFUSED
        sleep(0.1 * 1.2**i)
        retry
      end
      break
    end

    yield
  ensure
    Process.kill('TERM', pid)
  end

  describe '#assess' do
    subject { goal.assess }

    before do
      stub_request(:get, "http://0.0.0.0:#{port}/api/v1/gems")
        .with(headers: { 'Authorization' => correct_authorization })
        .to_return(status: 200, body: rubygems_gems_response_body)

      stub_request(:get, "http://0.0.0.0:#{port}/api/v1/gems")
        .with(headers: { 'Authorization' => incorrect_authorization })
        .to_return(status: 401, body: 'unauthorized')
    end

    context 'incorrect authorization' do
      let(:config_authorization) { incorrect_authorization }

      it 'raises' do
        expect { subject }.to raise_error(
          RuntimeError, 'Authorization failed'
        )
      end
    end

    context 'correct authorization' do
      let(:config_authorization) { correct_authorization }

      context 'response does not include requested gem' do
        let(:rubygems_gems_response_body) { JSON.dump([{ name: 'giraffe' }]) }

        it 'raises' do
          expect { subject }.to raise_error(
            RuntimeError, 'List of owned gems does not include request gem'
          )
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

  describe '#achieved?' do
    # TODO
  end

  describe '#try_achieve' do
    subject { goal.try_achieve }

    let(:config_authorization) { 'not really relevant :/' }

    around do |ex|
      WebMock.disable_net_connect!(allow_localhost: true)
      ex.run
      WebMock.disable_net_connect!
    end

    example do
      run_fake_gem_server_while do
        expect { subject }
          .to change { Net::HTTP.get_response(URI.parse("http://localhost:#{port}/gems/donkey")) }
          .from(Net::HTTPNotFound)
          .to(Net::HTTPOK)
      end
    end

    # TODO
  end

  describe '#failure_reason' do
    # TODO
  end
end
