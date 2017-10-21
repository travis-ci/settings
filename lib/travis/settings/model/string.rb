require 'travis/settings/model/base'

module Travis
  module Settings
    module Model
      class String < Base
        def value
          super
        end

        def set(value)
          super
        end

        private

          def read
            value = attrs[:value]
            encrypted ? decrypt(value, prefix: true) : value
          end

          def write(value)
            value = encrypt(value, prefix: true) if encrypted
            attrs[:value] = value
          end
      end
    end
  end
end
