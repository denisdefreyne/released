describe Released::Goals::GitRefPushed do
  subject(:goal) do
    described_class.new(config)
  end

  let(:config) do
    {
      'working_dir' => 'local',
      'remote' => 'gitlab',
      'branch' => 'devel',
    }
  end

  let!(:local) do
    Git.init('local').tap do |g|
      g.config('user.name', 'Testy McTestface')
      g.config('user.email', 'testface@example.com')

      g.chdir { File.write('hello.txt', 'hi there') }
      g.add('hello.txt')
      g.commit('Add greeting')
      g.branch('devel').checkout
    end
  end

  let!(:remote) do
    Git.init('remote')
  end

  before do
    local.add_remote('gitlab', './remote')
  end

  describe '#achieved?' do
    subject { goal.achieved? }

    context 'not pushed' do
      it { is_expected.not_to be }
    end

    context 'pushed, but not right rev' do
      before do
        goal.try_achieve

        local.chdir { File.write('bye.txt', 'bye now') }
        local.add('bye.txt')
        local.commit('Add farewell')
        local.branch('devel').checkout
      end

      it { is_expected.not_to be }
    end

    context 'pushed' do
      before { goal.try_achieve }
      it { is_expected.to be }
    end
  end

  describe '#try_achieve' do
    subject { goal.try_achieve }

    example do
      expect(remote.branches['devel']).to be_nil
      subject
      expect(remote.branches['devel'].gcommit.sha).to eql(local.branches['devel'].gcommit.sha)
    end
  end

  describe '#failure_reason' do
    subject { goal.failure_reason }
    it { is_expected.to eql('HEAD does not exist on gitlab/devel') }
  end
end
