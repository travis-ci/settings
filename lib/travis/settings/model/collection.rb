require 'travis/settings/model/base'

module Travis
  module Settings
    module Model
      class Collection < Base
        KEYS = %i(scope key type owner_id owner_type source)

        def items
          attrs[:items]
        end

        def to_h
          hash = KEYS.map { |key| [key, send(key)] }.to_h
          hash[:items] = items.map(&:to_h)
          hash
        end
      end
    end
  end
end
