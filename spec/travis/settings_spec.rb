describe Settings::Group do
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
          internal: true,
          alias: [:aliased]
      end
    end

    let(:owner) { create(:user) }
    let(:sets)  { const.new(owner) }

    it 'raises if the owner does not match' do
      expect { const.new(create(:repo))[:comic_sans] }.to raise_error(Settings::UnknownSetting)
    end

    describe 'all' do
      it { expect(sets.all.map(&:key)).to eq [:comic_sans] }
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

    describe 'alias' do
      it { expect(sets[:aliased].key).to eq :other }
    end

    it 'to_h' do
      expect(sets[:comic_sans].to_h).to eq(
        scope: :beta_features,
        key: :comic_sans,
        owner_id: owner.id,
        owner_type: 'User',
        value: false,
        type: :bool,
        source: :default
      )
    end
  end

  describe 'owner settings' do
    let(:const) do
      Class.new(described_class) do
        int :by_queue_max,
          owner: [:user, :org],
          scope: :concurrency,
          requires: :by_queue_enabled,
          default: 5

        bool :by_queue_enabled,
          owner: [:user, :org],
          scope: :concurrency,
          internal: true
      end
    end

    let(:sets) { const.new(create(:org)) }
    it { expect(sets.all.map(&:key)).to eq [] }
    it { expect(sets.all(internal: true).map(&:key)).to eq [:by_queue_enabled] }

    describe 'enable' do
      describe 'allowed' do
        before { sets[:by_queue_enabled].enable }
        before { sets[:by_queue_max].set(10) }
        it { expect(sets.all.map(&:key)).to include :by_queue_max }
        it { expect(sets[:by_queue_max].value).to eq 10 }
      end

      describe 'not allowed' do
        it { expect(sets.all.map(&:key)).to_not include :by_queue_max }
        it { expect(sets[:by_queue_max].value).to eq 5 }
        it { expect { sets[:by_queue_max].set(10) }.to raise_error Settings::InactiveSetting }
      end
    end
  end

  describe 'repo settings' do
    let(:const) do
      Class.new(described_class) do
        int :timeout,
          owner: [:owners, :user, :org, :repo],
          scope: :repo,
          inherit: [:owner, :owners],
          default: ->(s) { s.config[:timeout] || 60 * 60 },
          max: :max_timeout,
          min: 0 # default

        int :max_timeout,
          owner: [:owners, :user, :org, :repo],
          scope: :repo,
          inherit: [:owner, :owners],
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
      describe 'from the owner' do
        before { const.new(user)[:timeout].set(10) }
        it { expect(timeout.source).to eq :owner }
        it { expect(timeout.value).to eq 10 }
      end

      describe 'from the owner group' do
        let(:owners) { create(:owner_group, owner_id: user.id, owner_type: 'User') }
        before { const.new(owners)[:timeout].set(10) }
        it { expect(timeout.source).to eq :owners }
        it { expect(timeout.value).to eq 10 }
      end
    end

    describe 'exceeding max value' do
      describe 'with the default max value' do
        it { expect { timeout.set(7201) }.to raise_error Settings::InvalidValue }
      end

      describe 'with a custom max value on the owner' do
        before { const.new(user)[:max_timeout].set(1) }
        it { expect { timeout.set(2) }.to raise_error Settings::InvalidValue }
      end

      describe 'with a custom max value on the repo' do
        before { const.new(repo)[:max_timeout].set(1) }
        it { expect { timeout.set(2) }.to raise_error Settings::InvalidValue }
      end
    end
  end

  describe 'env_vars' do
    let(:user)   { create(:user) }
    let(:var)    { Settings.env_vars(user).first }
    let(:record) { Settings::Record::EnvVar.first }

    describe 'public' do
      before { create(:env_var, owner: user, name: 'foo', value: 'FOO', public: true) }
      it { expect(var.to_h).to eq 'foo' => 'FOO' }
      it { expect(record.read_attribute(:value)).to start_with '--ENCR--' }
    end

    describe 'private' do
      before { create(:env_var, owner: user, name: 'foo', value: 'FOO', public: false) }
      it { expect(var.to_h).to eq 'foo' => 'FOO' }
      it { expect(record.read_attribute(:value)).to start_with '--ENCR--' }
    end
  end

  describe 'keys' do
    let(:user)   { create(:user) }
    let(:key)    { Settings.ssh_keys(user).first }
    let(:record) { Settings::Record::SshKey.first }

    before { create(:ssh_key, owner: user, key: '1234', description: 'description') }
    it { expect(key.key).to eq '1234' }
    it { expect(key.description).to eq 'description' }
    it { expect(record.read_attribute(:key)).to start_with '--ENCR--' }
  end
end
