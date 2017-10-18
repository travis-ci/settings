require 'forwardable'

module Travis
  module Settings
    class Setting < Struct.new(:group, :attrs, :definition)
      extend Forwardable
      def_delegators :definition, :key, :scope, :inherit, :internal, :requires, :type

      def defined?
        attrs.key?(:value)
      end

      def active?
        requires.nil? || group.resolve(requires)
      end

      def value
        if attrs.key?(:value)
          @source = definition.owner_key(attrs[:owner_type])
          attrs[:value]
        elsif inherited
          value, @source = inherited
          value # TODO use default if undefined
        else
          @source = :default
          default
        end
      end

      def set(value)
        raise InactiveSetting.new(key, group.owner) unless active?
        attrs[:value] = value
        store.save
      end

      def delete
        attrs.delete(:value)
        store.delete
      end

      def source
        value unless instance_variable_defined?(:@source)
        @source
      end

      KEYS = %i(scope key value type source)

      def to_h
        KEYS.map { |key| [key, send(key)] }.to_h
      end

      private

        def inherited
          group.inherit(inherit, key) if inherit
        end

        def default
          group.resolve(definition.default)
        end

        def error(msg)
          group.errors << msg
          false
        end

        def store
          Store.new(attrs)
        end
    end

    class Int < Setting
      def value
        cast(super)
      end

      def set(value)
        value = Integer(value)
        validate(value)
        super(value)
      end

      private

        def validate(value)
          invalid(value) if min && value < min
          invalid(value) if max && value > max
        end

        def invalid(value)
          raise InvalidValue.new(key, value)
        end

        def min
          group.resolve(definition.min) || 0
        end

        def max
          group.resolve(definition.max)
        end

        def default
          cast(super)
        end

        def cast(value)
          Integer(value) if value
        end
    end

    class String < Setting
      def value
        super
      end

      def set(value)
        super
      end
    end

    class Bool < Setting
      def value
        super == 'true'
      end

      def set(value)
        super((!!value).to_s)
      end

      def enabled?
        value
      end

      def enable
        set(true)
      end

      def disable
        delete
      end
    end
  end
end
