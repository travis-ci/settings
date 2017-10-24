module Travis
  module Settings
    module Definition
      OWNERS = {
        global: 'NilClass',
        owners: 'OwnerGroup',
        repo:   'Repository',
        org:    'Organization',
        user:   'User'
      }

      class Base < Struct.new(:opts)
        %i(key scope inherit default min max requires).each do |key|
          define_method(key) { opts[key] }
        end

        %i(encrypted internal).each do |key|
          define_method(key) { !!opts[key] }
        end

        def keys
          [key] + self.alias
        end

        def alias
          Array(opts[:alias])
        end

        def owner?(owner)
          opts[:owner].any? { |key| OWNERS[key] == owner.class.name }
        end

        def owner_key(name)
          OWNERS.invert[name]
        end

        def instance(*args)
          factory.instance(*args)
        end
      end

      class Setting < Base
        def type
          opts[:type]
        end
      end

      class Collection < Base
        def type
          :collection
        end

        def item
          Setting.new(opts)
        end
      end
    end
  end
end
