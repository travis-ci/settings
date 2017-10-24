module Travis
  module Settings
    module Definition
      class Collection < Struct.new(:opts)
        %i(key scope inherit default min max requires).each do |key|
          define_method(key) { opts[key] }
        end

        %i(encrypted internal).each do |key|
          define_method(key) { !!opts[key] }
        end

        def type
          :collection
        end

        def owner?(owner)
          opts[:owner].any? { |key| OWNERS[key] == owner.class.name }
        end

        def owner_key(name)
          OWNERS.invert[name]
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
