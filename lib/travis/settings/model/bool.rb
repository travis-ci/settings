require 'travis/settings/model/base'

module Travis
  module Settings
    module Model
      class Bool < Base
        def value
          cast(super)
        end

        def set(value)
          super(value ? 't' : 'f')
        end

        def enabled?
          value
        end

        def enable
          set('t')
        end

        def disable
          delete
        end

        private

          def write(value)
            raise InvalidConfig.new('Cannot encrypt int values') if encrypted
            super
          end

          def cast(value)
            value.is_a?(::String) ? value == 't' : !!value
          end
      end
    end
  end
end
