describe Travis::Settings::Lookup do
  let(:owner)  { create(:user) }
  let(:defin)  { Travis::Settings::Definition::Setting.new(key: :key, type: type, default: 0) }
  let(:lookup) { described_class.new(nil, [defin], owner) }
  subject { lookup.run[:key] }

  describe 'types' do
    describe 'bool' do
      let(:type) { :bool }
      it { should be_a Travis::Settings::Model::Bool }
    end

    describe 'int' do
      let(:type) { :int }
      it { should be_a Travis::Settings::Model::Int }
    end

    describe 'string' do
      let(:type) { :string }
      it { should be_a Travis::Settings::Model::String }
    end
  end

  describe 'record' do
    let(:type) { :int }

    describe 'exists' do
      let!(:record) { create(:setting, key: :key, owner: owner, value: 1) }
      it { expect(subject.set?).to be true }
      it { expect(subject.attrs[:key]).to eq :key }
      it { expect(subject.attrs[:id]).to eq record.id }
      it { expect(subject.attrs[:owner_id]).to eq owner.id }
      it { expect(subject.attrs[:owner_type]).to eq 'User' }
      it { expect(subject.value).to eq 1 }
    end

    describe 'does not exists' do
      it { expect(subject.set?).to be false }
      it { expect(subject.attrs[:key]).to eq :key }
      it { expect(subject.attrs[:id]).to be nil }
      it { expect(subject.attrs[:owner_id]).to eq owner.id }
      it { expect(subject.attrs[:owner_type]).to eq 'User' }
      it { expect(subject.value).to eq 0 }
    end
  end
end
