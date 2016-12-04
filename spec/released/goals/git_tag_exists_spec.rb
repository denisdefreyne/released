describe Released::Goals::GitTagExists do
  subject(:goal) do
    described_class.new(config)
  end

  let(:config) do
    {
      'working_dir' => 'local',
      'name' => '1.3',
      'ref' => config_ref,
    }.merge(config_extra)
  end

  let(:config_extra) { {} }

  let(:config_ref) { 'HEAD' }

  let!(:local) do
    Git.init('local').tap do |g|
      g.config('user.name', 'Testy McTestface')
      g.config('user.email', 'testface@example.com')

      g.chdir { File.write('hello.txt', 'hi there') }
      g.add('hello.txt')
      g.commit('Add greeting')
      g.branch('devel').checkout
      g.add_tag('sweet')
    end
  end

  describe '#achieved?' do
    subject { goal.achieved? }

    context 'not tagged' do
      it { is_expected.not_to be }
    end

    context 'tagged, but wrong rev' do
      before do
        local.add_tag('1.3')

        local.chdir { File.write('bye.txt', 'bye now') }
        local.add('bye.txt')
        local.commit('Add farewell')
      end

      it { is_expected.not_to be }
    end

    context 'tagged' do
      before do
        local.add_tag('1.3')
      end

      it { is_expected.to be }
    end
  end

  describe '#try_achieve' do
    subject { goal.try_achieve }

    let(:created_tag) { local.tags.find { |t| t.name == '1.3' } }

    context 'referencing HEAD' do
      let(:config_ref) { 'HEAD' }

      example do
        expect(created_tag).to be_nil
        subject
        expect(local.tag('1.3').sha).to eql(local.object('HEAD').sha)
      end
    end

    context 'referencing branch' do
      let(:config_ref) { 'devel' }

      example do
        expect(created_tag).to be_nil
        subject
        expect(local.tag('1.3').sha).to eql(local.object('HEAD').sha)
      end
    end

    context 'referencing sha' do
      let(:config_ref) { local.object('devel').sha }

      example do
        expect(created_tag).to be_nil
        subject
        expect(local.tag('1.3').sha).to eql(local.object('HEAD').sha)
      end
    end

    context 'referencing tag' do
      let(:config_ref) { local.object('sweet').sha }

      example do
        expect(created_tag).to be_nil
        subject
        expect(local.tag('1.3').sha).to eql(local.object('HEAD').sha)
      end
    end

    # TODO: test signing

    context 'annotated' do
      let(:config_ref) { 'HEAD' }
      let(:config_extra) { { 'annotated' => true, 'message' => 'sweet new version yo' } }

      example do
        expect(created_tag).to be_nil
        subject

        tag = local.tag('1.3')
        expect(local.tag('1.3').sha).not_to eql(local.object('HEAD').sha)
        expect(local.tag('1.3').contents).to match(local.object('HEAD').sha)
        # expect(local.tag('1.3').message).to eql('sweet new version yo')

        # FIXME: messag is prepended with a space… ruby-git issue?
      end
    end
  end

  describe '#failure_reason' do
    subject { goal.failure_reason }

    context 'not tagged' do
      it { is_expected.to eql('no tag named 1.3 exists') }
    end

    context 'tagged, but wrong rev' do
      before do
        local.add_tag('1.3')

        local.chdir { File.write('bye.txt', 'bye now') }
        local.add('bye.txt')
        local.commit('Add farewell')
      end

      it { is_expected.to eql('tag named 1.3 points to different rev') }
    end
  end
end
