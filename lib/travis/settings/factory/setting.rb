module Travis
  module Settings
    module Factory
      class Setting < Struct.new(:definition, :group, :owner, :records)
        def instance
          const.new(group, attrs, definition)
        end

        def const
          Settings::Model.const_get(definition.type.to_s.titleize)
        end

        def attrs
          attrs = { key: definition.key }
          attrs = attrs.merge(symbolize(record.attributes)) if record
          attrs = attrs.merge(owner_type: owner.class.name, owner_id: owner.id) if owner
          attrs
        end

        def record
          records.is_a?(Array) ? records.first : records
        end

        def symbolize(hash)
          hash.map { |key, value| [key.to_sym, value] }.to_h
        end
      end
    end
  end
end
