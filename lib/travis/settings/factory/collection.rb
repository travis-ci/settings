module Travis
  module Settings
    module Factory
      class Collection < Struct.new(:definition, :group, :owner, :records)
        def instance
          Model::Collection.new(group, attrs, definition)
        end

        def attrs
          {
            owner_id: owner.id,
            owner_type: owner.class.name,
            items: items
          }
        end

        def items
          records.map do |record|
            factory_for(record).instance
          end
        end

        def factory_for(record)
          Setting.new(definition.item, group, owner, record)
        end
      end
    end
  end
end
