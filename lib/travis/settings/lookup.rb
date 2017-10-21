module Travis
  module Settings
    class Lookup < Struct.new(:group, :definitions, :owner)
      def run
        settings.map { |setting| [setting.key, setting] }.to_h
      end

      private

        def settings
          definitions.map { |definition| instance_for(definition) }
        end

        def instance_for(definition)
          const_for(definition).new(group, attrs_for(definition.key), definition)
        end

        def const_for(definition)
          Settings::Model.const_get(definition.type.to_s.titleize)
        end

        def attrs_for(key)
          record = record_for(key)
          attrs = { key: key }
          attrs = attrs.merge(symbolize(record.attributes)) if record
          attrs = attrs.merge(owner_type: owner.class.name, owner_id: owner.id) if owner
          attrs
        end

        def record_for(key)
          records.detect { |record| record.key == key }
        end

        def records
          @records ||= Record::Setting.where(key: definitions.map(&:key), owner: owner).all
        end

        def symbolize(hash)
          hash.map { |key, value| [key.to_sym, value] }.to_h
        end
    end
  end
end
