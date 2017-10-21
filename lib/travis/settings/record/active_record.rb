require 'active_record'

module Travis
  module Settings
    module Record
      class EnvVar < ActiveRecord::Base
        belongs_to :owner, polymorphic: true
      end

      class Setting < ActiveRecord::Base
        belongs_to :owner, polymorphic: true

        def key
          super&.to_sym
        end

        def attributes
          super.merge(key: key)
        end
      end
    end
  end
end
