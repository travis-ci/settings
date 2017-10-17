describe Travis::Settings::Group do
  describe 'flags' do
    let(:const) do
      Class.new(described_class) do
        bool :comic_sans,
          owner: [:user],
          scope: :beta_features,
          default: false

        bool :other,
          owner: [:user],
          scope: :other,
          internal: true
      end
    end

    let(:sets) { const.new(create(:user)) }

    describe 'all' do
      it { expect(sets.all.map(&:key)).to eq [:comic_sans, :other] }
      it { expect(sets.all(:beta_features).map(&:key)).to eq [:comic_sans] }
      it { expect(sets.all(internal: true).map(&:key)).to eq [:other] }
    end

    describe 'enabled?' do
      it { expect(sets[:comic_sans].enabled?).to be false }
    end

    describe 'enable' do
      before { sets[:comic_sans].enable }
      it { expect(sets[:comic_sans].enabled?).to be true }
    end

    describe 'disable' do
      before { sets[:comic_sans].enable }
      before { sets[:comic_sans].disable }
      it { expect(sets[:comic_sans].enabled?).to be false }
    end

    describe 'to_h' do
      let(:hash) { sets[:comic_sans].to_h }
      it do
        expect(hash).to eq(
          scope: :beta_features,
          key: :comic_sans,
          value: false,
          type: :bool,
          source: :default
        )
      end
    end
  end

  describe 'owner settings' do
    let(:const) do
      Class.new(described_class) do
        int :by_queue_max,
          owner: [:user, :org],
          scope: :concurrency,
          requires: :by_queue_enabled

        bool :by_queue_enabled,
          owner: [:user, :org],
          scope: :concurrency,
          internal: true
      end
    end

    let(:sets) { const.new(create(:org)) }
    it { expect(sets.all(internal: true).map(&:key)).to include :by_queue_enabled }

    describe 'enable' do
      describe 'allowed' do
        before { sets[:by_queue_enabled].enable }
        before { sets[:by_queue_max].set(10) }
        it { expect(sets.all.map(&:key)).to include :by_queue_max }
        it { expect(sets[:by_queue_max].value).to eq 10 }
      end

      describe 'not allowed' do
        it { expect(sets.all.map(&:key)).to_not include :by_queue_max }
        it { expect { sets[:by_queue_max].set(10) }.to raise_error Travis::Settings::InactiveSetting }
      end
    end
  end

  describe 'repo settings' do
    let(:const) do
      Class.new(described_class) do
        int :timeout,
          owner: [:user, :org, :repo],
          scope: :repo,
          type: :integer,
          inherit: :owner,
          default: ->(s) { s.config[:timeout] || 60 * 60 },
          max: :max_timeout,
          min: 0 # default

        int :max_timeout,
          owner: [:global, :user, :org, :repo],
          scope: :repo,
          inherit: :owner,
          default: ->(s) { s.config[:max_timeout] || 2 * 60 * 60 },
          internal: true
      end
    end

    let(:user) { create(:user) }
    let(:repo) { create(:repo, owner: user) }
    let(:sets) { const.new(repo) }
    let(:timeout) { sets.reset[:timeout] }

    it { expect(sets.all.map(&:key)).to include :timeout }
    it { expect(sets.all(internal: true).map(&:key)).to include :max_timeout }

    describe 'not given a value' do
      it { expect(timeout.source).to eq :default }
      it { expect(timeout.value).to eq 3600 }
    end

    describe 'given a value' do
      before { timeout.set(10) }
      it { expect(timeout.source).to eq :repo }
      it { expect(timeout.value).to eq 10 }
    end

    describe 'inheriting a value' do
      before { const.new(user)[:timeout].set(10) }
      it { expect(timeout.source).to eq :owner }
      it { expect(timeout.value).to eq 10 }
    end

    describe 'exceeding max value' do
      describe 'with the default max value' do
        it { expect { timeout.set(7201) }.to raise_error Travis::Settings::InvalidValue }
      end

      describe 'with a custom max value on the owner' do
        before { const.new(user)[:max_timeout].set(1) }
        it { expect { timeout.set(2) }.to raise_error Travis::Settings::InvalidValue }
      end

      describe 'with a custom max value on the repo' do
        before { const.new(repo)[:max_timeout].set(1) }
        it { expect { timeout.set(2) }.to raise_error Travis::Settings::InvalidValue }
      end
    end
  end
end
