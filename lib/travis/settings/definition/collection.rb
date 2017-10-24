require 'travis/settings/definition/base'

module Travis
  module Settings
    module Definition
      class Collection < Base
        def type
          :collection
        end

        def instance(group, owner, records)
          items = settings_for(group, owner, records)
          attrs = { owner_id: owner.id, owner_type: owner.class.name, items: items }
          Model::Collection.new(group, attrs, self)
        end

        def settings_for(group, owner, records)
          records.map { |record| spec.instance(group, owner, record) }
        end

        def spec
          Setting.new(opts)
        end
      end
    end
  end
end
