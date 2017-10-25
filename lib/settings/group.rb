module Settings
  class Group < Struct.new(:owner, :config)
    class << self
      %i(bool int str seqence).each do |type|
        define_method(type) do |key, attrs|
          define(key, attrs.merge(type: type))
        end
      end

      def collection(key, attrs)
        attrs = attrs.merge(key: key, item_type: attrs[:type])
        definitions << Definition::Collection.new(attrs)
      end

      def define(key, attrs)
        # TODO validate that only type: string can also be encrypted
        # maybe also validate that if any settings uses a :required flag
        # then that flag exists and it's a boolean type
        definitions << Definition::Setting.new(attrs.merge(key: key))
      end

      def definitions_for(owner)
        definitions.select { |d| d.owner?(owner) }
      end

      def resolve?(value)
        RESOLVE.include?(value.class)
      end

      def definitions
        @definitions ||= []
      end
    end

    def all(*args)
      opts, scope = args.last.is_a?(Hash) ? args.pop : {}, args.shift
      filter(settings.values, scope, opts)
    end

    def [](key)
      fetch(key) || raise(UnknownSetting, "Unknown setting #{key.inspect}")
    end

    def fetch(key)
      settings[key] || settings.values.detect { |v| v.alias?(key) }
    end

    def config
      super || {}
    end

    def reset
      @settings = nil
      self
    end

    RESOLVE = [Proc, Symbol]

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
      from.detect do |from|
        next unless source = owner.respond_to?(from) && owner.send(from)
        setting = self.class.new(source).fetch(key)
        break [setting.value, from] if setting&.set?
      end
    end

    private

      FILTERS = %i(by_active by_scope by_internal)

      def filter(objs, scope, opts)
        FILTERS.inject(objs) { |objs, filter| send(filter, objs, scope, opts) }
      end

      def by_scope(objs, scope, _)
        objs.select { |obj| scope.nil? || obj.scope == scope }
      end

      def by_internal(objs, _, opts)
        opts[:internal] ? objs.select(&:internal) : objs.reject(&:internal)
      end

      def by_active(objs, _, opts)
        opts[:internal] ? objs : objs.select(&:active?)
      end

      def settings
        @settings ||= Lookup.new(self, self.class.definitions_for(owner), owner).run
      end
  end
end
