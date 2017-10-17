module Travis
  module Settings
    class Group < Struct.new(:owner, :config)
      module Dsl
        def define(key, attrs)
          definitions << Definition.new(attrs.merge(key: key))
        end

        %i(bool int str).each do |type|
          define_method(type) do |key, attrs|
            define(key, attrs.merge(type: type))
          end
        end

        def definitions
          @definitions ||= []
        end

        def definitions_for(owner)
          definitions.select { |d| d.owner?(owner) }
        end
      end

      extend Dsl

      def all(*args)
        opts, scope = args.last.is_a?(Hash) ? args.pop : {}, args.shift
        filter(settings.values, scope, opts)
      end

      def [](key)
        settings[key] || raise("Unknown setting #{key.inspect}")
      end

      def config
        super || {}
      end

      def reset
        @settings = nil
        self
      end

      def resolve(value)
        case value
        when Symbol
          self[value].value
        when Proc
          value.call(self)
        else
          value
        end
      end

      def inherit(from, key)
        return unless owner.respond_to?(from)
        setting = self.class.new(owner.send(from))[key]
        [setting.value, from] if setting.defined?
      end

      private

        FILTERS = %i(by_active by_scope by_internal)

        def filter(objs, scope, opts)
          FILTERS.inject(objs) { |objs, filter| send(filter, objs, scope, opts) }
        end

        def by_active(objs, _, opts)
          objs.select(&:active?)
        end

        def by_scope(objs, scope, _)
          objs.select { |obj| scope.nil? || obj.scope == scope }
        end

        def by_internal(objs, _, opts)
          opts[:internal] ? objs.select(&:internal) : objs
        end

        def settings
          @settings ||= Lookup.new(self, self.class.definitions_for(owner), owner).run
        end
    end
  end
end
