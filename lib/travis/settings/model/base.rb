require 'travis/encrypt'

module Travis
  module Settings
    module Model
      class Base < Struct.new(:group, :attrs, :definition)
        include Travis::Encrypt

        %i(key scope encrypted inherit internal requires type).each do |key|
          define_method(key) { definition.send(key) }
        end

        %i(owner_id owner_type).each do |key|
          define_method(key) { attrs[key] }
        end

        def active?
          requires.nil? || group.resolve(requires)
        end

        def set?
          attrs.key?(:value)
        end

        def value
          if attrs.key?(:value)
            @source = definition.owner_key(attrs[:owner_type])
            read
          elsif inherited
            value, @source = inherited
            @source ? value : default
          else
            default
          end
        end

        def source
          value unless instance_variable_defined?(:@source)
          @source
        end

        def set(value)
          raise InactiveSetting.new(key, group.owner) unless active?
          write(value)
          attrs[:id] = store.save
        end

        def delete
          attrs.delete(:value)
          store.delete
        end

        KEYS = %i(scope key value type owner_id owner_type source)

        def to_h
          KEYS.map { |key| [key, send(key)] }.to_h
        end

        private

          def read
            attrs[:value]
          end

          def write(value)
            attrs[:value] = value
          end

          def inherited
            group.inherit(inherit, key) if inherit
          end

          def default
            @source = :default
            value = definition.default
            value = group.resolve(value) if Group.resolve?(value)
            value
          end

          def store
            Store.new(attrs)
          end
      end
    end
  end
end
