require 'travis/settings/model/base'

module Travis
  module Settings
    module Model
      class Int < Base
        def value
          cast(super)
        end

        def set(value)
          validate(value)
          super(Integer(value))
        end

        private

          def write(value)
            raise InvalidConfig.new('Cannot encrypt int values') if encrypted
            super
          end

          def validate(value)
            invalid(value) unless digits?(value)
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

          def digits?(value)
            value.to_s !~ /^[\D]$/
          end
      end
    end
  end
end
