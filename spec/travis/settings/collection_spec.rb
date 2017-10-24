describe Travis::Settings::Model::Collection do
  let(:const) do
    Class.new(Travis::Settings::Group) do
      collection :keys,
        type: :string,
        owner: [:repo],
        scope: :scope

      bool :foo, owner: [:repo], scope: :scope
    end
  end

  let(:repo)  { create(:repo) }
  let(:sets)  { const.new(repo) }

  describe 'empty' do
    it 'to_h' do
      expect(sets[:keys].to_h).to eq(
        scope: :scope,
        key: :keys,
        owner_id: repo.id,
        owner_type: 'Repository',
        type: :collection,
        source: :default,
        items: []
      )
    end
  end

  describe 'existing records' do
    let!(:one) { create(:setting, key: :keys, owner: repo, value: 'one') }
    let!(:two) { create(:setting, key: :keys, owner: repo, value: 'two') }

    it 'to_h' do
      expect(sets[:keys].to_h).to eq(
        scope: :scope,
        key: :keys,
        owner_id: repo.id,
        owner_type: 'Repository',
        type: :collection,
        source: :default,
        items: [
          {
            scope: :scope,
            key: :keys,
            value: 'one',
            type: :string,
            owner_id: repo.id,
            owner_type: 'Repository',
            source: :repo
          },
          {
            scope: :scope,
            key: :keys,
            value: 'two',
            type: :string,
            owner_id: repo.id,
            owner_type: 'Repository',
            source: :repo
          },
        ]
      )
    end
  end
end
