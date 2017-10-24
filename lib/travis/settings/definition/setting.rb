require 'travis/settings/definition/base'

module Travis
  module Settings
    module Definition
      class Setting < Base
        def instance(group, owner, record)
          record = record.first if record.is_a?(Array)
          const.new(group, attrs_for(owner, record), self)
        end

        def const
          Settings::Model.const_get(type.to_s.titleize)
        end

        def attrs_for(owner, record)
          attrs = { key: key }
          attrs = attrs.merge(symbolize(record.attributes)) if record
          attrs = attrs.merge(owner_type: owner.class.name, owner_id: owner.id) if owner
          attrs
        end

        def symbolize(hash)
          hash.map { |key, value| [key.to_sym, value] }.to_h
        end
      end
    end
  end
end
