describe Released::Goals::GemPushed, stdio: true do
  subject(:goal) do
    described_class.new(config)
  end

  let(:config) do
    {
      'name' => gem_name,
      'version' => gem_version,
      'authorization' => authorization,
      'rubygems_base_url' => rubygems_base_url,
    }
  end

  let(:gem_name) { 'nanoc' }
  let(:gem_version) { '4.4.2' }
  let(:authorization) { raise 'override me' }
  let(:rubygems_base_url) { 'https://rubygems.org' }

  let(:correct_authorization) { '83f5b7b9516c4342068cc60063a75de09bdb44d3' }
  let(:incorrect_authorization) { '66666666666666666666666666666666' }

  before do
    gemspec =
      <<~STRING
        Gem::Specification.new do |s|
          s.name    = 'nanoc'
          s.version = '4.4.2'

          s.summary = 'the best thing ever'
          s.author  = 'Denis Defreyne'
          s.email   = 'denis.defreyne@stoneship.org'
          s.license = 'MIT'

          s.files   = []
        end
      STRING

    File.write('donkey.gemspec', gemspec)
    system('gem', 'build', '--silent', 'donkey.gemspec')
  end

  describe '#assess' do
    subject { goal.assess }

    context 'incorrect authorization' do
      let(:authorization) { incorrect_authorization }

      it 'raises' do
        VCR.use_cassette('goals__gem_pushed_spec__assess__incorrect_auth') do
          expect { subject }.to raise_error(
            RuntimeError, 'Authorization failed'
          )
        end
      end
    end

    context 'correct authorization' do
      let(:authorization) { correct_authorization }

      context 'response does not include requested gem' do
        let(:gem_name) { 'definitely_not_nanoc' }

        it 'raises' do
          VCR.use_cassette('goals__gem_pushed_spec__assess__correct_auth_but_gem_not_present') do
            expect { subject }.to raise_error(
              RuntimeError, 'List of owned gems does not include request gem'
            )
          end
        end
      end

      context 'response includes requested gem' do
        it 'raises' do
          VCR.use_cassette('goals__gem_pushed_spec__assess__correct_auth_and_gem_present') do
            expect { subject }.not_to raise_error
          end
        end
      end
    end
  end

  describe '#achieved?' do
    # TODO
  end

  describe '#try_achieve' do
    subject { goal.try_achieve }

    let(:rubygems_repo) do
      Gems::Client.new(
        key: '83f5b7b9516c4342068cc60063a75de09bdb44d3',
        host: 'https://rubygems.org',
      )
    end

    let(:authorization) { correct_authorization }

    example do
      VCR.use_cassette('goals__gem_pushed_spec___try_achieve__step_a') do
        expect(rubygems_repo.gems.any? { |g| g['name'] == 'nanoc' && g['version'] == '4.4.2' }).not_to be
      end

      VCR.use_cassette('goals__gem_pushed_spec___try_achieve__step_b') do
        subject
      end

      VCR.use_cassette('goals__gem_pushed_spec___try_achieve__step_c') do
        expect(rubygems_repo.gems.any? { |g| g['name'] == 'nanoc' && g['version'] == '4.4.2' }).to be
      end
    end
  end

  describe '#failure_reason' do
    # TODO
  end
end
