describe Settings::Model do
  let(:owner) { create(:user) }
  let(:repo)  { create(:repo, owner: owner) }
  let(:const) { Class.new(Settings::Group) }
  let(:group) { const.new(repo, {}) }
  let(:defin) { Settings::Definition::Setting.new(opts) }
  let(:opts)  { { scope: :scope, key: :key, owner: [:owners, :user, :repo], type: type, default: false } }
  let(:attrs) { { key: :key, owner_id: repo.id, owner_type: 'Repository' } }
  let(:model) { described_class::Bool.new(group, attrs, defin) }
  let(:type)  { :bool }

  before { const.definitions << defin }

  it 'to_h' do
    expect(model.to_h).to eq(
      scope: :scope,
      key: :key,
      owner_id: repo.id,
      owner_type: 'Repository',
      value: false,
      type: :bool,
      source: :default
    )
  end

  describe 'set?' do
    describe 'given a value attr' do
      before { attrs.update(value: 'true') }
      it { expect(model.set?).to be true }
    end

    describe 'given no value attr' do
      it { expect(model.set?).to be false }
    end
  end

  describe 'active?' do
    describe 'no requires option defined' do
      it { expect(model.active?).to be true }
    end

    describe 'requires :other' do
      before { opts.update(requires: :other) }

      describe 'defaults to true' do
        let(:other) { { key: :other, owner: [:user, :repo], type: :bool, default: true } }
        before { const.definitions << Settings::Definition::Setting.new(other) }
        it { expect(model.active?).to be true }
      end

      describe 'value record exists' do
        let(:other) { { key: :other, owner: [:user, :repo], type: :bool } }
        before { const.definitions << Settings::Definition::Setting.new(other) }
        before { create(:setting, key: :other, owner: repo, value: true) }
        it { expect(model.active?).to be true }
      end

      describe 'value record does not exist' do
        let(:other) { { key: :other, owner: [:user, :repo], type: :bool } }
        before { const.definitions << Settings::Definition::Setting.new(other) }
        it { expect(model.active?).to be false }
      end
    end
  end

  describe 'value and source' do
    describe 'given a value attr' do
      before { attrs.update(value: 't') }
      it { expect(model.value).to be true }
      it { expect(model.source).to eq :repo }
    end

    describe 'inheritance' do
      before { defin.opts.update(inherit: [:owner, :owners]) }

      describe 'given a value record for the owner' do
        before { create(:setting, key: :key, owner: owner, value: true) }
        it { expect(model.value).to be true }
        it { expect(model.source).to eq :owner }
      end

      describe 'given a value record for the owner group' do
        let(:owners) { create(:owner_group, owner_id: owner.id, owner_type: 'User') }
        before { create(:setting, key: :key, owner: owners, value: true) }
        it { expect(model.value).to be true }
        it { expect(model.source).to eq :owners }
      end
    end

    describe 'default' do
      it { expect(model.value).to be false }
      it { expect(model.source).to eq :default }
    end
  end

  let(:record) { Settings::Record::Setting.where(key: :key, owner: repo).first }

  describe 'set' do
    describe 'a bool' do
      before { model.set(true) }
      it { expect(record.key).to eq :key }
      it { expect(record.owner).to eq repo }
      it { expect(record.value).to eq 't' }
      it { expect(model.value).to be true }
    end

    describe 'an int' do
      let(:model) { described_class::Int.new(group, attrs, defin) }
      let(:type)  { :int }
      before { model.set(1) }
      it { expect(record.value).to eq '1' }
      it { expect(model.value).to eq 1 }
    end

    describe 'a string' do
      let(:model) { described_class::String.new(group, attrs, defin) }
      let(:type)  { :string }
      before { model.set('string') }
      it { expect(record.value).to eq 'string' }
      it { expect(model.value).to eq 'string' }
    end

    describe 'when not enabled' do
      let(:other) { { key: :other, owner: [:user, :repo], type: :bool } }
      before { opts.update(requires: :other) }
      before { const.definitions << Settings::Definition::Setting.new(other) }
      it { expect(model.value).to be false }
      it { expect { model.set(true) }.to raise_error Settings::InactiveSetting }
    end

    describe 'when enabled' do
      let(:other) { { key: :other, owner: [:user, :repo], type: :bool } }
      before { opts.update(requires: :other) }
      before { const.definitions << Settings::Definition::Setting.new(other) }
      before { create(:setting, key: :other, owner: repo, value: true) }
      it { expect { model.set(true) }.to change { model.value }.from(false).to(true) }
    end
  end

  describe 'encrypted' do
    before { opts.update(encrypted: true) }

    describe 'a bool' do
      let(:model) { described_class::Bool.new(group, attrs, defin) }
      let(:type)  { :bool }
      it { expect { model.set(true) }.to raise_error Settings::InvalidConfig }
    end

    describe 'an int' do
      let(:model) { described_class::Int.new(group, attrs, defin) }
      let(:type)  { :int }
      it { expect { model.set(1) }.to raise_error Settings::InvalidConfig }
    end

    describe 'a string' do
      let(:model) { described_class::String.new(group, attrs, defin) }
      let(:type)  { :string }
      before { model.set('string') }
      it { expect(record.value).to start_with '--ENCR--' }
      it { expect(model.value).to eq 'string' }
    end
  end

  describe 'delete' do
    before { model.set(true) }
    before { model.delete }
    it { expect(record).to be nil }
  end
end
